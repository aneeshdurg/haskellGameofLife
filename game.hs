module Main where


import Control.Monad    (msum)
import Happstack.Server
    ( Response, ServerPart, Method(POST)
    , BodyPolicy(..), decodeBody, defaultBodyPolicy
    , dir, look, nullConf, ok, simpleHTTP
    , toResponse, methodM
    )
import Happstack.Server.Types (Response, addHeader)
import Data.List        (delete)
import qualified Data.Text.Lazy as L

keys :: Int -> Int -> [Int]
keys l x = delete x $ row l (x+l) ++ row l x ++ row l (x-l) 
  where row l x
          | 0<=x && x<l*l = map preserveRow thisRow
          | x>=l*l = row l (x `mod` l)
          | x<0 = row l (l*l + x) 
          where thisRow = [x`mod`l-1, x`mod`l, x`mod`l+1]
                preserveRow = (\y->y`mod`l+l*(x `div` l))

action :: Int -> Int -> [Int] -> Int
action l x xs = if (s==3)||(s==2&& xs!!x==1) then 1 else 0   
  where s=sum $ map (xs!!) $ keys l x

step ::[Int] -> [Int]
step xs = [l]++map (\x->action l x $ tail xs) [0..l*l-1]
  where l = head xs

main :: IO ()
main = simpleHTTP nullConf $ handlers

myPolicy :: BodyPolicy
myPolicy = (defaultBodyPolicy "/tmp/" 0 1000 1000)

handlers :: ServerPart Response
handlers =
    do decodeBody myPolicy
       msum [ processRequest ]

processRequest :: ServerPart Response
processRequest =
    do methodM POST
       stateStr <- look "state"
       let state = read stateStr :: [Int]
       let newState = step state
       let r = toResponse (show newState)
       ok $ addHeader "Access-Control-Allow-Origin" "*" r
