


#module

    #enum global rAX = 0
    #enum global rBX
    #enum global rCX
    #enum global rDX
    #enum global rSI
    #enum global rDI
    #enum global rBP
    #enum global rSP

    #enum global rAH = 0
    #enum global rBH
    #enum global rCH
    #enum global rDH

    #enum global rAL = 0
    #enum global rBL
    #enum global rCL
    #enum global rDL

    #enum global rCS = 0
    #enum global rDS
    #enum global rES
    #enum global rSS

    #enum global rIP = 0
    #enum global rFL



    #enum global fCF = %0000000000000001
    #enum global fPF = %0000000000000010
    #enum global fAF = %0000000000001000
    #enum global fZF = %0000000000100000
    #enum global fSF = %0000000001000000
    #enum global fTF = %0000000010000000
    #enum global fIF = %0000000100000000
    #enum global fDF = %0000001000000000
    #enum global fOF = %0000010000000000

    #enum global MAX8B   = 0xFF
    #enum global MAX16B  = 0xFFFF
    #enum global MAX32B  = 0xFFFFFFFF
    #enum global MAX8BS  = 0x7F
    #enum global MAX16BS = 0x7FFF
    #enum global MAX32BS = 0x7FFFFFFF

    #enum global ZERO = 0

    // レジスタ初期化
    // 引数：なし
    // 影響：なし
    // 戻り値：なし
    #deffunc initRegister

        dim vbin_CPUresistorG, 8    // AX BX CX DX SI DI BP SP
        dim vbin_CPUresistorS, 4    // CS DS ES SS
        dim vbin_CPUresistorE, 2    // IP FL
        vbin_CPUresistorE.1 = 0xF000

    return

    #deffunc checkDataB var cdb_data    // データが8bit符号なし整数の範囲を超えているか
        if ( ( cdb_data > MAX8B ) or ( cdb_data < 0 ) ) : {
            cdb_data = MAX8B && cdb_data
        }
    return

    #deffunc checkDataW var cdw_data    // データが16bit符号なし整数の範囲を超えているか
        if ( ( cdw_data > MAX16B ) or ( cdw_data < 0 ) ) : {
        cdw_data = MAX16B && cdw_data
    }
    return

    #deffunc checkDataD var cdd_data    // データが32bit符号なし整数の範囲を超えているか
        if ( ( cdd_data > MAX32B ) or ( cdd_data < 0 ) ) : {
        cdd_data = MAX32B && cdd_data
    }
    return

    // データに応じてフラグを建てる
    #deffunc checkFlagB var cfb_data, int cfb_checkFlags
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  AF
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF
        
        // check priority
        // CF > PF = ZF = SF = OF

        if ( cfb_checkFlags && fCF ) : {
            if ( cfb_data > MAX8B ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fCF
                cfb_data = ( cfb_data && 0xFFFFFF00 )
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fCF)
            }
        }

        if ( cfb_checkFlags && fPF ) : {
            if ( cfb_data && 0x01 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fPF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fPF)
            }
        }

        if ( cfb_checkFlags && fZF ) : {
            if ( cfb_data == 0 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fZF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fZF)
            }
        }

        if ( cfb_checkFlags && fSF ) : {
            if ( ( cfb_data && 0x80 ) ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fSF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fSF)
            }
        }

        if ( cfb_checkFlags && fOF ) : {
            if ( cfb_data > MAX8BS ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fOF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fOF)
            }
        }

    return

    #deffunc checkFlagBcmp var cfb_datacmp, int cfb_checkFlagscmp
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  AF
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF
        
        // check priority
        // CF > PF = ZF = SF = OF

        if ( cfb_checkFlagscmp && fCF ) : {
            if ( cfb_datacmp > MAX8B ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fCF
                cfb_datacmp = ( cfb_datacmp && 0xFFFFFF00 )
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fCF)
            }
        }

        if ( cfb_checkFlagscmp && fPF ) : {
            if ( cfb_datacmp && 0x01 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fPF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fPF)
            }
        }

        if ( cfb_checkFlagscmp && fZF ) : {
            if ( cfb_datacmp == 0 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fZF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fZF)
            }
        }

        if ( cfb_checkFlagscmp && fSF ) : {
            if ( ( cfb_datacmp && 0x80 ) or ( cfb_datacmp < 0 ) ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fSF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fSF)
            }
        }

        if ( cfb_checkFlagscmp && fOF ) : {
            if ( cfb_datacmp > MAX8BS ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fOF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fOF)
            }
        }

    return

    #deffunc checkFlagW var cfw_data, int cfw_checkFlags
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  (AF)
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF
        
        // check priority
        // CF > PF = ZF = SF = OF

        if ( cfw_checkFlags && fCF ) : {
            if ( cfw_data > MAX16B ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fCF
                cfw_data = ( cfw_data && 0xFFFF0000 )
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fCF)
            }
        }

        if ( cfw_checkFlags && fPF ) : {
            if ( cfw_data && 0x0001 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fPF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fPF)
            }
        }

        if ( cfw_checkFlags && fZF ) : {
            if ( cfw_data == 0 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fZF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fZF)
            }
        }

        if ( cfw_checkFlags && fSF ) : {
            if ( cfw_data && 0x8000 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fSF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fSF)
            }
        }

        if ( cfw_checkFlags && fOF ) : {
            if ( cfw_data > MAX16BS ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fOF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fOF)
            }
        }

    return

    #deffunc checkFlagWcmp var cfw_datacmp, int cfw_checkFlagscmp
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  (AF)
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF
        
        // check priority
        // CF > PF = ZF = SF = OF

        if ( cfw_checkFlagscmp && fCF ) : {
            if ( cfw_datacmp > MAX16B ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fCF
                cfw_datacmp = ( cfw_datacmp && 0xFFFF0000 )
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fCF)
            }
        }

        if ( cfw_checkFlagscmp && fPF ) : {
            if ( cfw_datacmp && 0x0001 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fPF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fPF)
            }
        }

        if ( cfw_checkFlagscmp && fZF ) : {
            if ( cfw_datacmp == 0 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fZF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fZF)
            }
        }

        if ( cfw_checkFlagscmp && fSF ) : {
            if ( ( cfw_datacmp && 0x8000 ) or ( cfw_datacmp < 0 ) ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fSF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fSF)
            }
        }

        if ( cfw_checkFlagscmp && fOF ) : {
            if ( cfw_datacmp > MAX16BS ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fOF
            } else {
                writeResistorWe rFL, fetchResistorWe(rFL) && notx(fOF)
            }
        }

    return

    #deffunc checkFlagD var cfd_data, int cfd_checkFlags
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  (AF)
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF
        
        // check priority
        // CF > PF = ZF = SF = OF

        if ( cfd_checkFlags && fCF ) : {
            if ( cfd_data > 0x00000000FFFFFFFF ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fCF
                cfd_data = ( cfd_data && 0xFFFFFFFF00000000 )
            }
        }

        if ( cfd_checkFlags && fPF ) : {
            if ( cfd_data && 0x00000001 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fPF
            }
        }

        if ( cfd_checkFlags && fZF ) : {
            if ( cfd_data == 0 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fZF
            }
        }

        if ( cfd_checkFlags && fSF ) : {
            if ( cfd_data && 0x80000000 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fSF
            }
        }

        if ( cfd_checkFlags && fOF ) : {
            if ( cfd_data && 0x80000000 ) : {
                writeResistorWe rFL, fetchResistorWe(rFL) || fOF
            }
        }

    return

    // フラグをテスト
    #defcfunc TestFlag int tfw_checkFlags
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  (AF)
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF

        tfw_result = 0

        if ( tfw_checkFlags && fCF ) : {
            if ( fetchResistorWe(rFL) && fCF ) : {
                tfw_result += fCF
            }
        }

        if ( tfw_checkFlags && fPF ) : {
            if ( fetchResistorWe(rFL) && fPF ) : {
                tfw_result += fPF
            }
        }

        if ( tfw_checkFlags && fAF ) : {
            if ( fetchResistorWe(rFL) && fAF ) : {
                tfw_result += fAF
            }
        }

        if ( tfw_checkFlags && fZF ) : {
            if ( fetchResistorWe(rFL) && fZF ) : {
                tfw_result += fZF
            }
        }

        if ( tfw_checkFlags && fSF ) : {
            if ( fetchResistorWe(rFL) && fSF ) : {
                tfw_result += fSF
            }
        }

        if ( tfw_checkFlags && fTF ) : {
            if ( fetchResistorWe(rFL) && fTF ) : {
                tfw_result += fPF
            }
        }

        if ( tfw_checkFlags && fIF ) : {
            if ( fetchResistorWe(rFL) && fIF ) : {
                tfw_result += fIF
            }
        }

        if ( tfw_checkFlags && fDF ) : {
            if ( fetchResistorWe(rFL) && fDF ) : {
                tfw_result += fDF
            }
        }

        if ( tfw_checkFlags && fOF ) : {
            if ( fetchResistorWe(rFL) && fOF ) : {
                tfw_result += fOF
            }
        }

    return tfw_result

    // フラグをクリア
    #deffunc clearFlag int cf_checkFlags
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  (AF)
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF

        if ( cf_checkFlags && fCF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111111111110
        }

        if ( cf_checkFlags && fPF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111111111101
        }

        if ( cf_checkFlags && fAF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111111110111
        }

        if ( cf_checkFlags && fZF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111111011111
        }

        if ( cf_checkFlags && fSF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111110111111
        }

        if ( cf_checkFlags && fTF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111101111111
        }

        if ( cf_checkFlags && fIF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111111011111111
        }

        if ( cf_checkFlags && fDF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111110111111111
        }

        if ( cf_checkFlags && fOF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) && %1111101111111111
        }

    return

    // フラグをセット
    #deffunc setFlag int sf_checkFlags
        // checkFlags
        // 0000 0000-0000 0001  CF
        // 0000 0000-0000 0010  PF
        // 0000 0000-0000 1000  (AF)
        // 0000 0000-0010 0000  ZF
        // 0000 0000-0100 0000  SF
        // 0000 0000-1000 0000  (TF)
        // 0000 0001-0000 0000  (IF)
        // 0000 0010-0000 0000  (DF)
        // 0000 0100-0000 0000  OF

        if ( sf_checkFlags && fCF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fCF
        }

        if ( sf_checkFlags && fPF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fPF
        }

        if ( sf_checkFlags && fAF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fAF
        }

        if ( sf_checkFlags && fZF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fZF
        }

        if ( sf_checkFlags && fSF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fSF
        }

        if ( sf_checkFlags && fTF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fTF
        }

        if ( sf_checkFlags && fIF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fIF
        }

        if ( sf_checkFlags && fDF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fDF
        }

        if ( sf_checkFlags && fOF ) : {
            writeResistorWe rFL, fetchResistorWe(rFL) || fOF
        }

    return

    // 各レジスタへのアクセス
    #defcfunc fetchResistorWg int resistorWgIDf
    return vbin_CPUresistorG.resistorWgIDf

    #defcfunc fetchResistorWs int resistorWsIDf
    return vbin_CPUresistorS.resistorWsIDf

    #defcfunc fetchResistorWe int resistorWeIDf
    return vbin_CPUresistorE.resistorWeIDf

    #defcfunc fetchResistorBgh int resistorBghIDf
    return ( vbin_CPUresistorG.resistorBghIDf && 0xFF00 ) >> 8

    #defcfunc fetchResistorBgl int resistorBglIDf
    return ( vbin_CPUresistorG.resistorBglIDf && 0x00FF )


    #deffunc writeResistorWg int resistorWgIDw, int dataWgw
        vbin_CPUresistorG.resistorWgIDw = dataWgw
    return

    #deffunc writeResistorWs int resistorWsIDw, int dataWsw
        vbin_CPUresistorS.resistorWsIDw = dataWsw
    return

    #deffunc writeResistorWe int resistorWeIDw, int dataWew
        vbin_CPUresistorE.resistorWeIDw = dataWew
    return

    #deffunc writeResistorBgh int resistorBghIDw, int dataBghw
        poke vbin_CPUresistorG.resistorBghIDw, 0x01, dataBghw
    return

    #deffunc writeResistorBgl int resistorBglIDw, int dataBglw
        poke vbin_CPUresistorG.resistorBglIDw, 0x00, dataBglw
    return

    #deffunc saveError str saverr_type

        vstr_temp = ""
        notesel vstr_temp
        noteadd "==Emulator Error Dump=="
        noteadd "Emulator compile date: "+ __date__ +" "+ __time__ +""
        noteadd "Compiler version: "+ __hspver__ +""
        noteadd strf("Error occured date: %04d/%02d/%02d %02d:%02d:%02d.%03d", gettime(0), gettime(1), gettime(3), gettime(4), gettime(5), gettime(6), gettime(7) )
        noteadd "Type: "+ saverr_type
        noteadd "+Resistor"

        vbin_CPUtmp = fetchResistorWe(rFL)
        vbin_CPUtmpS = ""
        repeat 16
            
            switch cnt
            case 0
                if ( vbin_CPUtmp && fCF ) : vbin_CPUtmpS.0 += "C" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 2
                if ( vbin_CPUtmp && fPF ) : vbin_CPUtmpS.0 += "P" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 4
                if ( vbin_CPUtmp && fAF ) : vbin_CPUtmpS.0 += "A" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 6
                if ( vbin_CPUtmp && fZF ) : vbin_CPUtmpS.0 += "Z" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 7
                if ( vbin_CPUtmp && fSF ) : vbin_CPUtmpS.0 += "S" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 8
                if ( vbin_CPUtmp && fTF ) : vbin_CPUtmpS.0 += "T" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 9
                if ( vbin_CPUtmp && fIF ) : vbin_CPUtmpS.0 += "I" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 10
                if ( vbin_CPUtmp && fDF ) : vbin_CPUtmpS.0 += "D" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            case 11
                if ( vbin_CPUtmp && fOF ) : vbin_CPUtmpS.0 += "O" : else : vbin_CPUtmpS.0 += "-"
            swbreak
            swend

        loop

        noteadd "AX="+ strf("%04X", fetchResistorWg(rAX)) +" BX="+ strf("%04X", fetchResistorWg(rBX)) +" CX="+ strf("%04X", fetchResistorWg(rCX)) +" DX="+ strf("%04X", fetchResistorWg(rDX)) +" SI="+ strf("%04X", fetchResistorWg(rSI)) +" DI="+ strf("%04X", fetchResistorWg(rDI)) +" BP="+ strf("%04X", fetchResistorWg(rBP)) +" SP="+ strf("%04X", fetchResistorWg(rSP)) +""
        noteadd "CS="+ strf("%04X", fetchResistorWs(rCS)) +" DS="+ strf("%04X", fetchResistorWs(rDS)) +" ES="+ strf("%04X", fetchResistorWs(rES)) +" SS="+ strf("%04X", fetchResistorWs(rSS)) +" IP="+ strf("%04X", fetchResistorWe(rIP)) +" "+ vbin_CPUtmpS.0 +""
        noteadd ""
        noteadd "+Other infomation"
        noteadd "TIME="+ gettick(0) +" ms"
        noteadd "TICK="+ emu_vint_executedCmd@ +""

        notesave "error.txt"
        noteunsel

    return

#global