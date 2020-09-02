{-
  This file defines the messaging system's basic functions and types.
  It exports all the functions and types above the word "PRIVATE" below,
  so they can be used in Demo.hs.
-}

{-# LANGUAGE FlexibleInstances #-}

module MsgSys(
  name,
  password,
  message,
  emptyMsgSys,
  alerter,
  register,
  login,
  findUser,
  allUsers,
  userPair,
  send,
  userMessages,
  messageSize,
  composeActions,
  asUser,
  display,
  Name,
  User,
  Password,
  LoggedInUser,
  Message,
  UserPair,
  MsgSys
) where

import Data.List

name :: String -> Name
name = wrapString

password :: String -> Password
password = wrapString

message :: String -> Message
message = wrapString

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
send :: Message -> UserPair -> MsgSys -> MsgSys
send _ Nothing msgSys = msgSys
send msg (Just rawPair) msgSys =
  msgSys {allEnvelopes = Envelope rawPair msg : allEnvelopes msgSys}

userMessages :: MsgSys -> User -> [Message]
userMessages msgSys user = map envMessage envelopes
  where envelopes = filter (involvesUser user) (allEnvelopes msgSys)

messageSize :: Message -> Int
messageSize = length . unwrapString

composeActions :: [MsgSys -> MsgSys] -> MsgSys -> MsgSys
composeActions = foldr (.) id

asUser :: LoggedInUser -> User
asUser = fmap credsUser

display :: Displayable a => a -> IO ()
display = formattedDisplay (Format "" "\n")

type Name = StringWrapper NameTag
type User = Maybe RawUser
type Password = StringWrapper PasswordTag
type LoggedInUser = Maybe RawCredentials
type Message = StringWrapper MessageTag
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

alerterName = name "Alerter"
alerterPassword = password "Extremely secure password"

wrapString :: String -> StringWrapper tag
wrapString = StringWrapper

unwrapString :: StringWrapper tag -> String
unwrapString (StringWrapper string) = string

rawCredentials :: Name -> Password -> RawCredentials
rawCredentials name password = RawCredentials (RawUser name) password

sameUser :: User -> RawCredentials -> Bool
sameUser user rawCreds = user == Just (credsUser rawCreds)

allRawUsers :: MsgSys -> [RawUser]
allRawUsers msgSys = map credsUser (allCredentials msgSys)

involvesUser :: User -> Envelope -> Bool
involvesUser user storedMsg =
  sameUser user (fst rawPair) || user == Just (snd rawPair)
  where rawPair = envRawUserPair storedMsg

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

data Envelope =
  Envelope {
    envRawUserPair :: RawUserPair,
    envMessage :: Message
  } deriving(Eq,Show)

-- MsgSys stores messages and credentials in lists, for the sake of simplicity.
-- This is good enough for a toy application like this, but it would not scale
-- well to a system that can handle billions ofusers and messages, as the
-- "register", "login", "findUser" and "userMessages" functions currently have
-- to iterate over the whole list.
--
-- MsgSys also stores Passwords in plain text - again, this is for simplicity.
-- Please don't do this in a real application! Follow OWASP's advice on password
-- storage: https://bit.ly/3gQTUNY
data MsgSys =
  MsgSys {
    allEnvelopes :: [Envelope],
    allCredentials :: [RawCredentials]
  } deriving(Eq,Show)

data StringWrapper tag = StringWrapper String deriving(Eq,Show)
data NameTag = NameTag deriving(Eq,Show)
data PasswordTag = PasswordTag deriving(Eq,Show)
data MessageTag = MessageTag deriving(Eq,Show)

-- =============================================================================
-- The code below allows you to use the "display" function to print readable
-- representations of instances most types defined in this module.
-- =============================================================================

data Format = Format {prefix::String, suffix::String} deriving(Eq,Show)
data Line = Line Char deriving(Eq,Show)
data Blank = Blank deriving(Eq,Show)

newLineFormat :: Format -> Format
newLineFormat format = format {suffix="\n"}

indent :: Format -> Format
indent format = format {prefix="  " ++ prefix format}

displayLn :: Displayable a => Format -> a -> IO ()
displayLn format = formattedDisplay (newLineFormat format)

prefixedDisplay :: Displayable a => Format -> String -> a -> IO ()
prefixedDisplay format pre =
  formattedDisplay format {prefix=prefix format ++ pre}

prefixedDisplayLn :: Displayable a => Format -> String -> a -> IO ()
prefixedDisplayLn format = prefixedDisplay (newLineFormat format)


class Displayable a where
  formattedDisplay :: Format -> a -> IO ()

instance Displayable MsgSys where
  formattedDisplay format msgSys = do
    dispLn doubleLine
    dispLn (wrapString "Messages (oldest first):")
    dispLn doubleLine
    displayList (indent format) (Line '-') (reverse (allEnvelopes msgSys))
    dispLn doubleLine
    dispLn (wrapString "Registered Users:")
    dispLn doubleLine
    displayList (indent format) Blank (map credsUser (allCredentials msgSys))
    formattedDisplay format doubleLine
    where
    dispLn :: Displayable a => a -> IO ()
    dispLn = displayLn format

    doubleLine = Line '='

instance Displayable Envelope where
  formattedDisplay format storedMsg = do
    displayLn format (envRawUserPair storedMsg)
    prefixedDisplay format "Message: " (envMessage storedMsg)

instance Displayable RawCredentials where
  formattedDisplay format creds = do
    prefixedDisplayLn format "User: " (credsUser creds)
    prefixedDisplay format "Password: " (credsPassword creds)

instance Displayable RawUser where
  formattedDisplay format (RawUser name) = formattedDisplay format name

instance Displayable RawUserPair where
  formattedDisplay format (from,to) = do
    prefixedDisplayLn format "From: " (credsUser from)
    prefixedDisplay format "To: " to

instance Displayable LoggedInUser where
  formattedDisplay format Nothing =
    formattedDisplay format (wrapString "[Login failed: check Name & Password]")

  formattedDisplay format (Just rawCreds) = formattedDisplay format rawCreds

instance Displayable User where
  formattedDisplay format Nothing =
    formattedDisplay format (wrapString "[User not found: check Name]")

  formattedDisplay format (Just rawUser) = formattedDisplay format rawUser

instance Displayable UserPair where
  formattedDisplay format Nothing =
    formattedDisplay format
      (wrapString "[Undefined UserPair: check Names and LoggedInUser Password]")

  formattedDisplay format (Just rawUserPair) =
    formattedDisplay format rawUserPair

instance Displayable (StringWrapper tag) where
  formattedDisplay format (StringWrapper string) = do
    putStr (prefix format)
    putStr string
    putStr (suffix format)

instance Displayable Line where
  formattedDisplay format (Line char) =
    formattedDisplay format (wrapString (replicate noChars char))
    where
    noChars = max 0 (80 - length (prefix format))

instance Displayable Blank where
  formattedDisplay _ Blank = return ()

instance Displayable a => Displayable [a] where
  formattedDisplay format = displayList format (Line '+')

displayList ::
  (Displayable separator, Displayable a) => Format -> separator -> [a] -> IO ()
displayList _ _ [] = return ()
displayList format _ [a] = do formattedDisplay format a
displayList format separator (a:as) = do
  displayLn format a
  displayLn format separator
  displayList format separator as
