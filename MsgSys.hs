{-
    This file defines the messaging system's basic functions and types.
    It exports all the functions and types above the word "PRIVATE" below,
    so they can be used in Demo.hs.
-}
module MsgSys(
    emptyMsgSys,
    alerter,
    register,
    login,
    findUser,
    allUsers,
    userPair,
    send,
    userMessages,
    composeActions,
    asUser,
    display,
    Name(Name),
    User,
    Password(Password),
    LoggedInUser,
    UserPair,
    MsgSys
) where

import Data.List

emptyMsgSys :: MsgSys
emptyMsgSys = register alerterName alerterPassword (MsgSys [] [])

alerter :: LoggedInUser
alerter = login alerterName alerterPassword emptyMsgSys

-- Note: this function only allows "name" to be registered once. If you try
-- to register it again, the MsgSys will not change
register :: Name -> Password -> MsgSys -> MsgSys
register name password msgSys =
    validateRegistration msgSys (rawCredentials name password)

login :: Name -> Password -> MsgSys -> LoggedInUser
login name password msgSys = validateLogin msgSys (rawCredentials name password)

findUser :: MsgSys -> Name -> User
findUser msgSys name =
    if null users then Nothing else Just (head users)
    where users = filter (== RawUser name) (allRawUsers msgSys)

allUsers :: MsgSys -> [User]
allUsers msgSys = map Just (allRawUsers msgSys)

userPair :: LoggedInUser -> User -> UserPair
userPair creds user = do
    rawCreds <- creds
    rawUser <- user
    Just (rawCreds, rawUser)

-- Note: the message will only be sent if the UserPair was created from a
-- LoggedInUser and User that are both registered in "msgSys".
-- The underscore symbol "_" is a placeholder for parameters that we don't care
-- about.
send :: String -> UserPair -> MsgSys -> MsgSys
send _ Nothing msgSys = msgSys
send msg (Just rawPair) msgSys =
    msgSys {allMessages = storedMessage rawPair msg : allMessages msgSys}

userMessages :: MsgSys -> User -> [String]
userMessages msgSys user = map messageString storedMsgs
    where storedMsgs = filter (involvesUser user) (allMessages msgSys)

composeActions :: [MsgSys -> MsgSys] -> MsgSys -> MsgSys
composeActions = foldr (.) id

asUser :: LoggedInUser -> User
asUser = fmap credsUser

data Name = Name String deriving(Eq,Show)
type User = Maybe RawUser
data Password = Password String deriving(Eq,Show)
type LoggedInUser = Maybe RawCredentials
type UserPair = Maybe RawUserPair


-- =============================================================================
--                                 PRIVATE
-- =============================================================================
-- The functions, and most of the types, below are hidden from other modules, to
-- prevent other modules from invalidating the state of a MsgSys (e.g. by
-- sending messages to/from unregistered Users). E.g. code in the Demo module
-- cannot call any of the functions below - it can only use the functions and
-- types listed in the export list (the list in parentheses at the top of this
-- file, after "module MsgSys").
--
-- Note however that if you load this module into ghci, it will give you full
-- access to everything. To do this, type ":l MsgSys".
-- =============================================================================

alerterName = Name "Alerter"
alerterPassword = Password "Extremely secure password"

rawCredentials :: Name -> Password -> RawCredentials
rawCredentials name password = RawCredentials (RawUser name) password

sameUser :: User -> RawCredentials -> Bool
sameUser user rawCreds = user == Just (credsUser rawCreds)

storedMessage :: RawUserPair -> String -> StoredMessage
storedMessage rawPair msg = StoredMessage rawPair (MessageString msg)

messageString :: StoredMessage -> String
messageString (StoredMessage _ (MessageString string)) = string

allRawUsers :: MsgSys -> [RawUser]
allRawUsers msgSys = map credsUser (allCredentials msgSys)

involvesUser :: User -> StoredMessage -> Bool
involvesUser user storedMsg =
    sameUser user (fst rawPair) || user == Just (snd rawPair)
    where rawPair = storedRawUserPair storedMsg

-- This function returns true if "msgSys" has RawCredentials that satisfy
-- "condition".
anyCredentialsSatisfy :: MsgSys -> (RawCredentials -> Bool) -> Bool
anyCredentialsSatisfy msgSys condition = any condition (allCredentials msgSys)

validateRegistration :: MsgSys -> RawCredentials -> MsgSys
validateRegistration msgSys rawCreds =
    if canRegister msgSys rawCreds
    then msgSys {allCredentials = rawCreds : allCredentials msgSys}
    else msgSys

-- RawCredentials can only register if the User and Password are defined (i.e.
-- not Nothing), and the User has not already registered
canRegister :: MsgSys -> RawCredentials -> Bool
canRegister msgSys rawCreds = not registered
    where
    user = Just (credsUser rawCreds)
    registered = anyCredentialsSatisfy msgSys (sameUser user)

validateLogin :: MsgSys -> RawCredentials -> LoggedInUser
validateLogin msgSys rawCreds =
    if anyCredentialsSatisfy msgSys (== rawCreds)
    then Just rawCreds
    else Nothing

data RawUser = RawUser Name deriving(Eq,Show)
type RawUserPair = (RawCredentials, RawUser)

data RawCredentials =
    RawCredentials {
        credsUser :: RawUser,
        credsPassword :: Password
    } deriving(Eq,Show)

data MessageString = MessageString String deriving(Eq,Show)
data StoredMessage =
    StoredMessage {
        storedRawUserPair :: RawUserPair,
        storedMessageString :: MessageString
    } deriving(Eq,Show)

data MsgSys =
    MsgSys {
        allMessages :: [StoredMessage],
        allCredentials :: [RawCredentials]
    } deriving(Eq,Show)


-- =============================================================================
-- The code below allows you to use the "display" function to display the
-- contents of MsgSys with more readable formatting.
-- =============================================================================

class Displayable a where
    display :: a -> IO ()

instance Displayable MsgSys where
    display msgSys = do
        display doubleLine
        putStrLn "Messages (oldest first):"
        display doubleLine
        sequence_ displayMsgs
        putStrLn "Registered Users:"
        display doubleLine
        sequence_ displayRegisteredUsers
        where
        doubleLine = Separator '='

        displayMsgs :: [IO ()]
        displayMsgs = map display (reverse (allMessages msgSys))

        displayRegisteredUsers :: [IO ()]
        displayRegisteredUsers =
            map (prefixDisplay "  ") (allCredentials msgSys)

instance Displayable StoredMessage where
    display storedMsg = do
        prefixDisplay "  From: " from
        prefixDisplay "  To: " to
        prefixDisplay "  Message: " (storedMessageString storedMsg)
        display (Separator '-')
        where
        (from, to) = storedRawUserPair storedMsg

instance Displayable RawCredentials where
    display creds = display (credsUser creds)

instance Displayable RawUser where
    display (RawUser (Name name)) = putStrLn name

instance Displayable MessageString where
    display (MessageString string) = putStrLn string

data Separator = Separator Char

instance Displayable Separator where
    display (Separator char) = putStrLn (replicate 80 char)

prefixDisplay :: Displayable a => String -> a -> IO ()
prefixDisplay prefix a = do
    putStr prefix
    display a
