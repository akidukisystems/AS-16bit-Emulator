#module

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