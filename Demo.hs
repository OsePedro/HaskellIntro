{-  
  This file contains the code that we went through in the presentation.

  It also contains a function "initialise", that creates "LoggedInUser"s "ose"
  and "pedro", and sends a few messages between them.
  To send a message to a "LoggedInUser", like "ose", you need to get a "User" 
  from it by typing "user ose", etc. You can then make this the second parameter
  of the "UserPair" -- e.g. "Pair alerter (user ose)".
-}

module Demo where

import MsgSys

(msgSys0,ose,pedro) = initialise
msgSys1 = send "ok..." (Pair pedro (user ose)) msgSys0

alertee :: User -> UserPair
alertee = Pair alerter

alert :: String -> User -> MsgSys -> MsgSys
alert msg user msgSys = send msg (alertee user) msgSys 

alertOutOfSpace :: User -> MsgSys -> MsgSys
alertOutOfSpace = alert "You're out of storage space"

messageLengths :: [String] -> [Int]
messageLengths = map length

-- Note: "sum" is provided by the standard library, so 
sumMessageLengths :: [String] -> Int
sumMessageLengths = sum . messageLengths

usedSpace :: MsgSys -> User -> Int
usedSpace msgSys user = sumMessageLengths (messages msgSys user)

-- Note: compose is defined in MsgSys.hs as:
--
--    compose = foldr (.) id
--
-- "id" is provided by the standard library. It behaves like the "emptyResult"
-- function near the end of the presentation. 
-- 
-- You can use compose to compose any list of "MsgSys -> MsgSys" functions into
-- a single function. E.g. see how it is used in "initialise" below.
alertMultiOutOfSpace :: [User] -> MsgSys -> MsgSys
alertMultiOutOfSpace users msgSys = compose (map alertOutOfSpace users) msgSys


initialise :: (MsgSys,LoggedInUser,LoggedInUser)
initialise = (msgSysWithMessages,ose,pedro)
  where
  oseName = Name "Ose"
  osePassword = Password "Ose's password"

  pedroName = Name "Pedro"
  pedroPassword = Password "Pedro's password"

  msgSysWithUsers :: MsgSys
  msgSysWithUsers = 
    compose [
      registerUser pedroName pedroPassword,
      registerUser oseName osePassword
    ] emptyMsgSys

  ose = login oseName osePassword msgSysWithUsers
  pedro = login pedroName pedroPassword msgSysWithUsers

  msgSysWithMessages :: MsgSys
  msgSysWithMessages =
    compose [
      send "I miss u ❤" (Pair ose (user pedro)),
      send "hey" (Pair pedro (user ose))
    ] msgSysWithUsers
