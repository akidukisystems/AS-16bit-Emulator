#module

	#deffunc splitMulti str in, array out, array sp

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

				vint_cnt = cnt

				foreach sp

					case sp.cnt

						if ( flag_spell ) : {

							poke out.arrayNum, index, peek ( inV, vint_cnt )
							poke out.arrayNum, index +1, 0x00

							index ++

						} else {

							arrayNum ++
							out.arrayNum = ""
							index = 0

						}

					swbreak

				loop
				
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