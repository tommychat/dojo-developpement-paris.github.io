module Parser (repl, normal, debug) where
import Data.Maybe

repl mode = interact (unlines . map mode . lines)

type Value = Integer

type Operation = Char
type Parser a = String -> [(a,String)]

data Token = V Value
           | Lambda Operation
           | Apply Token Token

normal :: String -> String
normal s = case (map fst . filter success . parse) s of
    [t] -> show (eval t)
    _ -> "Parsing of the expression failed" 

debug :: String -> String
debug s = case parse s of
    [] -> "error : incorrect prefix expression" 
    rs -> unlines [show (eval t) ++ " (" ++ s ++ ")"
                  | (t,s) <- rs]

success :: (a,String) -> Bool
success = null . snd

parse :: Parser Token
parse = expression

expression :: Parser Token
expression = number 
           <|> (unary <&> expression)
           <|> (binary <&> expression <&> expression)

number = spaces valueParser 
unary  = spaces unaryParser
binary = spaces binaryParser
           

valueParser :: Parser Token
valueParser s = case reads s of
    [(n,s')] | n >= 0 -> [(V n, s')]
    _ -> []  

fact n = product [1..n]

unaries = zip "-!" [negate, fact]
binaries= zip "+-*/%" [(+),(-),(*),div,mod]

unaryParser :: Parser Token
unaryParser (c:s) = case lookup c unaries of
    Nothing -> []
    Just f -> [(Lambda c,s)]
unaryParser _ = []

binaryParser :: Parser Token
binaryParser (c:s) = case lookup c binaries of
    Nothing -> []
    Just f -> [(Lambda c,s)]
binaryParser _ = []

spaces :: Parser a -> Parser a
spaces p (' ':rest) = spaces p rest
spaces p s       = p s

infixl 2 <|>
(<|>) :: Parser a -> Parser a -> Parser a 
(p <|> q) s = p s <> q s

infixl 3 <&>
(<&>) :: Parser Token -> Parser Token -> Parser Token
(p <&> q) s = case p s of
    [] -> []
    rs -> [(grow a b, s'')
          | (a,s') <- rs
          , (b,s'') <- q s']
    where
    grow :: Token -> Token -> Token
    grow (V a) _ = V a
    grow lam t = Apply lam t

eval :: Token -> Value
eval (V n) = n
eval (Apply (Lambda c) t) = let f = fromJust (lookup c unaries) in f (eval t)
eval (Apply (Apply (Lambda c) t) u) = let f = fromJust (lookup c binaries) in f (eval t) (eval u)
