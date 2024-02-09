/*

    split.as
        改良型文字列分割モジュール

*/

#module

	; 文字列を分割します
	; "" で囲まれた部分は分割しません
	; in=分割する文字列
	; out=分割後の文字列を格納する配列変数
	; sp=区切り文字（数値型）
	; 注意："" で囲まれた部分は分割されませんが、分割後の文字列からは "" は消去されます。
	; "" を残したい場合は splitExS を使用してください。
	#deffunc splitEx str in, array out, int sp

		inV = in
		arrayNum = 0
		index = 0
		flag_spell = 0

		if ( length ( out ) < 8 ) : {

			sdim out, strlen ( inV ) +1, 8
			
		} else {

			sdim out, strlen ( inV ) +1, length ( out )

		}
		

		repeat strlen ( inV )

			switch peek ( inV, cnt )

				case sp

					if ( flag_spell ) : {

						poke out.arrayNum, index, peek ( inV, cnt )
						poke out.arrayNum, index +1, 0x00

						index ++

					} else {

						arrayNum ++
						out.arrayNum = ""
						index = 0

					}

				swbreak

				case '"'

					if ( flag_spell ) : {

						flag_spell = 0

					} else {

						flag_spell = 1

					}

				swbreak

				default

					poke out.arrayNum, index, peek ( inV, cnt )
					poke out.arrayNum, index +1, 0x00

					index ++

				swbreak

			swend

		loop

		dim inV 
		dim arrayNum
		dim index
		dim flag_spell

	return

	; 文字列を分割します
	; "" で囲まれた部分は分割しません。ただし、分割後の文字列に "" は残ります。
	; in=分割する文字列
	; out=分割後の文字列を格納する配列変数
	; sp=区切り文字（数値型）
	#deffunc splitExS str in, array out, int sp

		inV = in
		arrayNum = 0
		index = 0
		flag_spell = 0

		if ( length ( out ) < 8 ) : {

			sdim out, strlen ( inV ) +1, 8
			
		} else {

			sdim out, strlen ( inV ) +1, length ( out )

		}
		

		repeat strlen ( inV )

			switch peek ( inV, cnt )

				case sp

					if ( flag_spell ) : {

						poke out.arrayNum, index, peek ( inV, cnt )
						poke out.arrayNum, index +1, 0x00

						index ++

					} else {

						arrayNum ++
						out.arrayNum = ""
						index = 0

					}

				swbreak

				case '"'

					poke out.arrayNum, index, peek ( inV, cnt )
					poke out.arrayNum, index +1, 0x00

					index ++

					if ( flag_spell ) : {

						flag_spell = 0

					} else {

						flag_spell = 1

					}

				swbreak

				default

					poke out.arrayNum, index, peek ( inV, cnt )
					poke out.arrayNum, index +1, 0x00

					index ++

				swbreak

			swend

		loop

		dim inV 
		dim arrayNum
		dim index
		dim flag_spell

	return


#global