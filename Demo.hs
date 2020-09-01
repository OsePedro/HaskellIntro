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
msgSys1 = send "ok..." (userPair pedro (asUser ose)) msgSys0

alertee :: User -> UserPair
alertee = userPair alerter

alert :: String -> User -> MsgSys -> MsgSys
alert msg user msgSys = send msg (alertee user) msgSys

alertOutOfSpace :: User -> MsgSys -> MsgSys
alertOutOfSpace = alert "You're out of storage space"

messageLengths :: [String] -> [Int]
messageLengths = map length

-- Note: the "sum" function that is defined in the presentation is provided by
-- the standard library.
sumMessageLengths :: [String] -> Int
sumMessageLengths = sum . messageLengths

usedSpace :: MsgSys -> User -> Int
usedSpace msgSys user = sumMessageLengths (userMessages msgSys user)

-- Note: composeActions is defined in MsgSys.hs as:
--
--    ccomposeChanges = foldr (.) id
--
-- "id" is provided by the standard library. It behaves like the "emptyResult"
-- function near the end of the presentation.
--
-- You can use "composeActions" to compose any list of (MsgSys -> MsgSys)
-- functions into a single function. E.g. see how it is used in "initialise"
-- below.
alertMultiOutOfSpace :: [User] -> MsgSys -> MsgSys
alertMultiOutOfSpace users msgSys =
  composeActions (map alertOutOfSpace users) msgSys


-- Note: Haskell uses indentation to define scopes, much like Python
initialise :: (MsgSys,LoggedInUser,LoggedInUser)
initialise = (msgSysWithMessages,ose,pedro)
  where
  oseName = name "Ose"
  osePassword = password "Ose's unguessable password"

  pedroName = name "Pedro"
  pedroPassword = password "Pedro's beautiful password"

  msgSysWithUsers :: MsgSys
  msgSysWithUsers =
    composeActions [
      register pedroName pedroPassword,
      register oseName osePassword
    ] emptyMsgSys

  ose = login oseName osePassword msgSysWithUsers
  pedro = login pedroName pedroPassword msgSysWithUsers

  msgSysWithMessages :: MsgSys
  msgSysWithMessages =
    composeActions [
      send "I miss u ❤" (userPair ose (asUser pedro)),
      send "hey" (userPair pedro (asUser ose))
    ] msgSysWithUsers
