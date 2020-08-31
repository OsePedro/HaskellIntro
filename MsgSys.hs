{- 
    This file defines the messaging system's basic functions and types.
    It exports all the functions and types above the word "PRIVATE" below,
    so they can be used in Demo.hs.
-}

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
    MsgSys
) where

import Data.List

emptyMsgSys :: MsgSys
emptyMsgSys = registerUser (name alerterUser) alerterPassword (MsgSys [] [])

alerter :: LoggedInUser
alerter = UserPassword alerterUser alerterPassword

login :: Name -> Password -> MsgSys -> LoggedInUser
login name password msgSys =
    let liUser = UserPassword (User name) password
    in  if isRegistered liUser msgSys then liUser else invalidUserPassword

-- Note: this function only allows "name" to be registered once. Thus, it 
-- doesn't allow you to change the "Password" of a registered "User".
registerUser :: Name -> Password -> MsgSys -> MsgSys
registerUser name password msgSys =
    let liUser = UserPassword (User name) password
    in  if liUser == invalidUserPassword || isRegistered liUser msgSys
        then msgSys
        else msgSys {registeredUsers = liUser : registeredUsers msgSys}

send :: String -> UserPair -> MsgSys -> MsgSys
send msg pair msgSys = 
    if isRegistered (sender pair) msgSys
    then msgSys {allMessages = StoredMessage pair msg : allMessages msgSys}
    else msgSys -- unregistered sender cannot send messages

messages :: MsgSys -> User -> [String]
messages msgSys user =
    let storedMsgs = filter (involvesUser user) (allMessages msgSys)
    in  map show storedMsgs

findUser :: MsgSys -> Name -> User
findUser msgSys queryName = 
    let users = filter ((== queryName) . name) (allUsers msgSys)
    in if null users then user invalidUserPassword else head users

allUsers :: MsgSys -> [User]
allUsers msgSys = map user (registeredUsers msgSys)

compose :: [MsgSys -> MsgSys] -> MsgSys -> MsgSys
compose = foldr (.) id

user :: UserPassword -> User
user = user'

password :: UserPassword -> Password
password = password'

type LoggedInUser = UserPassword
data UserPair = Pair LoggedInUser User deriving(Eq,Show)
data Name = Name String deriving(Eq,Show)
data Password = Password String deriving(Eq,Show)
data User = User {name :: Name} deriving(Eq)

-- =============================================================================
-- PRIVATE
-- =============================================================================

alerterPassword = Password "Extremely secure password"
alerterUser = User (Name "Alerter")
invalidUserPassword = UserPassword (User (Name "")) (Password "")

sender :: UserPair -> LoggedInUser
sender (Pair liUser _) = liUser

recipient :: UserPair -> User
recipient (Pair _ user) = user

involvesUser :: User -> StoredMessage -> Bool
involvesUser u storedMsg = 
    let pair = userPair storedMsg
    in  user (sender pair) == u || recipient pair == u

isRegistered :: UserPassword -> MsgSys -> Bool
isRegistered userPword msgSys = 
    any ((== user userPword) . user) (registeredUsers msgSys)

data UserPassword = 
    UserPassword {
        user' :: User,
        password' :: Password
    } deriving (Eq)

data StoredMessage = StoredMessage {userPair::UserPair, message::String}

data MsgSys = MsgSys {
    allMessages :: [StoredMessage],
    registeredUsers :: [UserPassword]
}

-- =============================================================================
-- The following allows you to use the "show" function to convert User, 
-- UserPassword, StoredMessage and MsgSys to nice String.
-- E.g. if you type "emptyMsgSys" in ghci, it will display the result of calling
-- "show emptyMsgSys"
-- =============================================================================

instance Show User where
    show (User (Name name)) = name

instance Show UserPassword where
    show userPassword = show (user userPassword)

instance Show StoredMessage where
    show storedMsg = 
        let (Pair from to) = userPair storedMsg
        in  "  From: "++show from++"\n  To: "++show to++"\n  Message: "++
            message storedMsg++"\n\n"

instance Show MsgSys where
    show msgSys = 
        let msgs     = concatMap show (reverse (allMessages msgSys))
            regUsers = concatMap ((++ "\n  ") . show) (registeredUsers msgSys)
        in  "Messages (oldest first):\n"++msgs ++ "Registered Users:\n  "++regUsers
