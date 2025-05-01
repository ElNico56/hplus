# h+

## commands

### literals and variables
- **`123`** Push the number 123.
- **`\abc`** Push the string 'abc'.
- **`abc:`** Pop and store in the variale 'abc'.
- **`abc`** Push value stored in 'abc'.
- **`Abc`** Execute value stored in 'abc'.
### stack manipulation
- **`))()`** Planet notation: keep-keep-drop-keep.
```
	1 2 3 4 ))()
1 2 4
```
- **`!))`** Planet eval: keep-keep, eval, push back kept values.
```
	1 2 3 4 {-} !))
-1 3 4
```
- **`!!`** Foreach.
```
	1 2 3 4 5 5[...]
[ 1 2 3 4 5 ]
	{10*} !!
[ 10 20 30 40 50 ]
```
- **`:`** Flip.
```
	10 20 :
20 10
```
- **`;`** Pop.
```
	10 20 ;
10
```
- **`?`** Ternary operator.
```
	0 10 20 ?
20
```
```
	1 10 20 ?
10
```
- **`.`** Duplicate.
```
	10 .
10 10
```
- **`,`** Over.
```
	10 20 ,
10 20 10
```
- **`>>`** R rot.
```
	10 20 30 >>
30 10 20
```
- **`<<`** L rot.
```
	10 20 30 <<
20 30 10
```
- **`>>>`** R rot with copy.
```
	10 20 30 >>>
30 10 20 30
```
- **`<<<`** L rot with copy.
```
	10 20 30 <<<
10 20 30 10
```
- **`[...]`** Pack.
```
	10 20 30 3[...]
[ 10 20 30 ]
```
- **`...`** Unpack.
```
	10 20 30 3[...]
[ 10 20 30 ]
	...
10 20 30
```
- **`{`** Open list.
- **`}`** Finish list.
```
	{ + - 10 a b c}
[ + - 10 a b c ]
```
- **`\`** Escape.
```
	\ +
+
```
- **`!`** Eval.
```
	10 20 \ + !
30
```
- **`$=`** Save.
- **`$`** Load.
```
	10 $=

	$
10
```
- **`#`** Call system function.
```
	10 \output#
10
```
### data manipulation
- **`||`** Absolute value.
- **`<>`** Range.
- **`|`** OR.
- **`&`** AND.
- **`^`** NOT.
- **`^^`** XOR.
- **`+`** Add.
- **`-`** Sub.
- **`*`** Mul.
- **`/`** Div.
- **`<`** Less than.
- **`>`** Greater than.
- **`=`** Equal.
- **`!=`** Unequal.
- **`[]`** Index.
- **`[]=`** Index assign.
