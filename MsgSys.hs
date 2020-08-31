{-
    This file defines the messaging system's basic functions and types.
    It exports all the functions and types above the word "PRIVATE" below,
    so they can be used in Demo.hs.
-}

{-# LANGUAGE FlexibleInstances #-}

module MsgSys(
    emptyMsgSys,
    alerter,
    login,
    registerUser,
    send,
    messages,
    findUser,
    allUsers,
    compose,
    LoggedInUser, user, password,
    UserPair(..),
    Name(..),
    Password(..),
    User(..),
    Displayable(..),
    MsgSys
) where

import Data.List

emptyMsgSys :: MsgSys
emptyMsgSys = registerUser alerterName alerterPassword (MsgSys [] [])

alerter :: LoggedInUser
alerter = login alerterName alerterPassword emptyMsgSys

login :: Name -> Password -> MsgSys -> LoggedInUser
login name password msgSys = validateLogin msgSys (loginAttempt name password)

-- Note: this function only allows "name" to be registered once. If you try
-- to register it again, the MsgSys will not change
registerUser :: Name -> Password -> MsgSys -> MsgSys
registerUser name password msgSys =
    if canRegister msgSys userPword
    then msgSys {registeredUsers = userPword : registeredUsers msgSys}
    else msgSys

    where userPword = UserPassword (User name) password

-- Note: the message will only be sent if the login attempt succeeded and the
-- recipient is a registered User. The underscore symbol "_" is a placeholder
-- for parameters that we don't care about.
send :: String -> UserPair -> MsgSys -> MsgSys
send _ (Pair LoginFailed _) msgSys = msgSys
send _ (Pair _ NonExistentUser) msgSys = msgSys
send msg pair msgSys =
    msgSys {allMessages = StoredMessage pair msg : allMessages msgSys}

messages :: MsgSys -> User -> [String]
messages msgSys user = map message storedMsgs
    where storedMsgs = filter (involvesUser user) (allMessages msgSys)

findUser :: MsgSys -> Name -> User
findUser msgSys queryName = if null users then NonExistentUser else head users
    where users = filter (== User queryName) (allUsers msgSys)

allUsers :: MsgSys -> [User]
allUsers msgSys = map upUser (registeredUsers msgSys)

compose :: [MsgSys -> MsgSys] -> MsgSys -> MsgSys
compose = foldr (.) id

user :: LoggedInUser -> User
user (LoggedIn userPword) = upUser userPword
user LoginFailed = NonExistentUser

password :: LoggedInUser -> Password
password (LoggedIn userPword) = upPassword userPword
password LoginFailed = UndefinedPassword

data UserPair = Pair LoggedInUser User deriving(Eq,Show)
data Name = Name String deriving(Eq,Show)
data Password = Password String | UndefinedPassword deriving(Eq,Show)
data User = User Name | NonExistentUser deriving(Eq,Show)

class Displayable a where
    display :: a -> IO ()


-- =============================================================================
-- PRIVATE
--
-- The functions, and most of the types, below are hidden from other modules
-- (i.e. they have been deliberately omitted from the export list in parentheses
-- at the top of this file, after "module MsgSys"). E.g. code in the Demo module
-- cannot call any of these functions. However, ghci will give you full access
-- to everything in this module, if you load the module into it. To do this,
-- type ":l MsgSys".
-- =============================================================================

alerterPassword = Password "Extremely secure password"
alerterName = Name "Alerter"
alerterUser = User alerterName

sender :: UserPair -> LoggedInUser
sender (Pair loggedInUser _) = loggedInUser

recipient :: UserPair -> User
recipient (Pair _ user) = user

involvesUser :: User -> StoredMessage -> Bool
involvesUser u storedMsg =
    let pair = userPair storedMsg
    in  user (sender pair) == u || recipient pair == u

-- This function returns true if msgSys has a UserPassword that satisfies
-- "condition".
hasSatisfyingUserPassword :: MsgSys -> (UserPassword -> Bool) -> Bool
hasSatisfyingUserPassword msgSys condition =
    any condition (registeredUsers msgSys)

validateLogin :: MsgSys -> LoginAttempt -> LoggedInUser
validateLogin msgSys (LoginAttempt userPword) =
    if hasSatisfyingUserPassword msgSys (== userPword)
    then LoggedIn userPword
    else LoginFailed

hasRegistered :: MsgSys -> User -> Bool
hasRegistered msgSys queryUser = hasSatisfyingUserPassword msgSys sameUser
    where
        sameUser :: UserPassword -> Bool
        sameUser existingUserPword = queryUser == upUser existingUserPword

-- UserPassword can only register if the User and Password are defined,
-- and the User has not already registered
canRegister :: MsgSys -> UserPassword -> Bool
canRegister _ (UserPassword NonExistentUser _) = False
canRegister _ (UserPassword _ UndefinedPassword) = False
canRegister msgSys userPword = not (hasRegistered msgSys (upUser userPword))


data LoginAttempt = LoginAttempt UserPassword deriving(Show)
data LoggedInUser = LoggedIn UserPassword | LoginFailed deriving(Eq,Show)

loginAttempt :: Name -> Password -> LoginAttempt
loginAttempt name password =
    LoginAttempt (
        UserPassword (User name) password
    )

data UserPassword =
    UserPassword {upUser :: User, upPassword :: Password} deriving(Eq,Show)

data StoredMessage =
    StoredMessage {userPair::UserPair, message::String} deriving(Show)

data MsgSys =
    MsgSys {
        allMessages :: [StoredMessage],
        registeredUsers :: [UserPassword]
    } deriving(Show)


-- =============================================================================
-- The code below allows you to use the "display" function to display the
-- contents of MsgSys with more readable formatting.
-- =============================================================================

instance Displayable MsgSys where
    display msgSys = do
        putStrLn "Messages (oldest first):"
        sequence_ displayMsgs
        putStrLn "Registered Users:"
        sequence_ displayRegisteredUsers
        where
            displayMsgs :: [IO ()]
            displayMsgs = map display (reverse (allMessages msgSys))

            displayRegisteredUsers :: [IO ()]
            displayRegisteredUsers = map (prefixDisplayLn "  ") (registeredUsers msgSys)

instance Displayable StoredMessage where
    display storedMsg = do
        prefixDisplayLn "  From: " from
        prefixDisplayLn "  To: " to
        prefixDisplayLn "  Message: " (message storedMsg)
        putStrLn ""
        where (Pair from to) = userPair storedMsg

instance Displayable LoggedInUser where
    display LoginFailed = putStr "[Login attempt failed]"
    display (LoggedIn userPword) = display userPword

instance Displayable UserPassword where
    display userPassword = display (upUser userPassword)

instance Displayable User where
    display (User (Name name)) = putStr name
    display NonExistentUser = putStr "[Non-existent User]"

instance Displayable String where
    display string = putStr string

prefixDisplayLn :: Displayable a => String -> a -> IO ()
prefixDisplayLn prefix a = do
    putStr prefix
    display a
    putStrLn ""
