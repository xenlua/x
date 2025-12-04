-- ts file was generated at discord.gg/25ms


return (function(...)
    local vu1 = {
        "",
        "9UHTmUgsF/==",
        "IjM02T+=",
        "qZXMZsMK9Dg9N5isq/==",
        "2yPO9sDYIp/n6AMvZe==",
        "2V4oNuua6sLxqyI+",
        "kX==",
        "mGu3kVhUg/==",
        "OVg1m3OM3y4W3DhrgX==",
        "krXuIKRikX==",
        "2AgI",
        "IcYd2T+=",
        "2ZCQq/==",
        "gsL1gZDrIc+=",
        "5ANTGC5UqJYHPsGT6a==",
        "9VPQNAgug/==",
        "fpCh3UiWGNE1svC+3rmquJhG5sI8BwVXVTxskGANeCx9JWmBmWtDJb4CAxi2c6RLKSNtnRIODHPXprsSrJQUuKmlK4c3gCjoDr3bs7lgbqeK/zE=",
        "cDLi2jPuF/==",
        "gsuuOUg3Ny5Ag3IR",
        "Ns6h2sa=",
        "cDLoma==",
        "mouQIe==",
        "5sC7Ns5d+APugs5pgs5J+e==",
        "IUDhgs6R",
        "2sLhIV6QNju1Ia==",
        "gZW5OVGd5CuUGp5iga==",
        "mUL1mUCQ",
        "Nj572TIu",
        "gsCr2sG=",
        "FZGnm34W6JMe65RvFe==",
        "2yA=",
        "IUC7Ie==",
        "NU5Q2Z5QmcPhmjMu",
        "mUhhNX==",
        "gc6Wmu4q6c51IoCDOa==",
        "IT6DmX==",
        "2y+=",
        "mT4G6Dhp63Cs3TIZ",
        "2s51",
        "NTPdqZWo",
        "GT4ymcPI2T4i6nhO",
        "cDLHIZv=",
        "gsLngVYi2jN=",
        "NjC1IsL7",
        "gZWamZ6B",
        "3GueFAiqPGPtmG5Mq/==",
        "cDL7IcPhgsCr2sG="
    }
    local function vu3(p2)
        return vu1[p2 - 6203]
    end
    local v4, v5, v6 = ipairs({
        {
            1,
            47
        },
        {
            1,
            24
        },
        {
            25,
            47
        }
    })
    local v7 = vu1
    while true do
        local v8
        v6, v8 = v4(v5, v6)
        if v6 == nil then
            break
        end
        while v8[1] < v8[2] do
            local v9 = v8[1]
            local v10 = v8[2]
            local v11 = v7[v8[2] ]
            local v12 = v7[v8[1] ]
            local v13 = v8[1] + 1
            v8[2] = v8[2] - 1
            v8[1] = v13
            v7[v10] = v12
            v7[v9] = v11
        end
    end
    local v14 = type
    local v15 = math.floor
    local v16 = string.char
    local v17 = string.sub
    local v18 = table.insert
    local v19 = table.concat
    local v20 = string.len
    local v21 = {
        I = 25,
        m = 24,
        u = 37,
        ["1"] = 46,
        E = 60,
        ["8"] = 42,
        B = 43,
        d = 50,
        y = 3,
        ["6"] = 13,
        z = 62,
        F = 30,
        e = 16,
        V = 7,
        L = 61,
        a = 48,
        A = 4,
        ["+"] = 8,
        ["4"] = 1,
        U = 54,
        o = 39,
        c = 23,
        j = 38,
        J = 36,
        R = 40,
        N = 28,
        ["9"] = 18,
        q = 26,
        ["2"] = 27,
        P = 17,
        ["3"] = 19,
        n = 51,
        X = 32,
        b = 31,
        l = 59,
        Y = 9,
        ["5"] = 21,
        t = 10,
        Z = 22,
        ["/"] = 0,
        D = 53,
        ["0"] = 47,
        T = 55,
        S = 15,
        x = 11,
        M = 49,
        v = 56,
        g = 29,
        Q = 52,
        W = 57,
        h = 33,
        s = 6,
        f = 58,
        k = 14,
        O = 12,
        r = 34,
        H = 44,
        C = 5,
        G = 20,
        w = 63,
        p = 35,
        i = 41,
        K = 2,
        ["7"] = 45
    }
    for v32 = 1, # v7 do
        local v23 = v7[v32]
        if v14(v23) == "string" then
            local v24 = v20(v23)
            local v25 = v32
            local v26 = 1
            local v27 = {}
            local v28 = 0
            local v29 = 0
            while v26 <= v24 do
                local v30 = v17(v23, v26, v26)
                local v31 = v21[v30]
                if v31 then
                    v28 = v28 + v31 * 64 ^ (3 - v29)
                    v29 = v29 + 1
                    if v29 == 4 then
                        v18(v27, v16(v15(v28 / 65536), v15(v28 % 65536 / 256), v28 % 256))
                        v29 = 0
                        v28 = 0
                    end
                elseif v30 == "=" then
                    v18(v27, v16(v15(v28 / 65536)))
                    if v24 <= v26 or v17(v23, v26 + 1, v26 + 1) ~= "=" then
                        v18(v27, v16(v15(v28 % 65536 / 256)))
                    end
                    break
                end
                v26 = v26 + 1
            end
            v7[v32] = v19(v27)
            local v32 = v25
        end
    end
    return (function(pu33, pu34, pu35, pu36, pu37, _, p38, pu39, _, pu40, pu41, pu42, pu43, pu44, pu45, pu46, pu47, pu48, pu49, pu50, pu51)
        local function v168(p52, p53, p54, p55)
            local v56 = nil
            local v57 = nil
            local v58 = nil
            local v59 = nil
            local v60 = nil
            local v61 = nil
            local v62 = nil
            local v63 = nil
            local v64 = nil
            local v65 = nil
            local v66 = nil
            local v67 = nil
            local v68 = nil
            local v69 = nil
            local v70 = nil
            local v71 = nil
            local v72 = nil
            local v73 = nil
            local v74 = nil
            local v75 = nil
            local v76 = nil
            local v77 = nil
            local v78 = nil
            local v79 = nil
            local v80 = nil
            local v81 = nil
            local v82 = nil
            local v83 = nil
            while p52 do
                if p52 < 8084859 then
                    if p52 < 4473812 then
                        if p52 < 1966295 then
                            if p52 < 895403 then
                                if p52 < 473853 then
                                    if p52 < 440724 then
                                        if p52 < 245404 then
                                            p52 = pu33[vu3(6226)]
                                            v57 = {}
                                        else
                                            p52 = 4374944
                                        end
                                    else
                                        p52 = 12830959
                                    end
                                elseif p52 < 712354 then
                                    p52 = 3665444
                                else
                                    v56[v59] = v59
                                    v71 = v59
                                    v61 = nil
                                    p52 = 9754910
                                end
                            elseif p52 < 1245407 then
                                if p52 < 1085926 then
                                    local v84 = pu33[vu3(6217)]
                                    v67 = vu3(6211)
                                    pu33[v67] = v84
                                    p52 = 6104330
                                else
                                    local v85 = vu3(6217)
                                    local v86 = vu3(6211)
                                    local v87 = pu33[v85]
                                    v57 = pu33[v86]
                                    pu33[vu3(6211)] = v87
                                    pu33[vu3(6217)] = v57
                                    v73 = pu45[p54[1] ]
                                    v80 = v73()
                                    p52 = 3665444
                                end
                            elseif p52 < 1647877 then
                                v80 = pu45[p54[2] ]
                                v72 = pu45[p54[3] ]
                                v57 = v80 == v72
                                v73 = v57
                                p52 = 15831192
                            else
                                v60 = v77 == v76
                                v62 = v60
                                p52 = 9374657
                            end
                        elseif p52 < 3565292 then
                            if p52 < 2669157 then
                                if p52 < 2355363 then
                                    if p52 < 2315671 then
                                        v60 = v60 + v83
                                        local v88 = not v67
                                        local v89 = v60 <= v62
                                        if not v88 then
                                            v89 = v88
                                        end
                                        local v90 = v62 <= v60
                                        if not v67 then
                                            v90 = v67
                                        end
                                        local v91 = v90 or v89
                                        v78 = 6533455
                                        if v91 then
                                            v91 = v78
                                        end
                                        v57 = 11547059
                                        p52 = v91 or v57
                                    else
                                        v67 = 0
                                        v59 = # v56
                                        v61 = v59 == v67
                                        p52 = 13655452
                                    end
                                else
                                    v62 = pu45[v79](1, 6)
                                    pu33[vu3(6217)] = v62
                                    v83 = pu33[vu3(6217)]
                                    v67 = 2
                                    p52 = v67 < v83 and 6210401 or 959739
                                end
                            elseif p52 < 3406402 then
                                v81 = vu3(6225)
                                v57 = pu33[v81]
                                v74 = v57
                                p52 = 14318803
                            else
                                p52 = pu45[p54[7] ] and 9461434 or 7611286
                            end
                        elseif p52 < 4032122 then
                            if p52 < 3819291 then
                                p52 = 1161739 or 8565669
                            else
                                local v92 = vu3(6240)
                                local v93 = vu3(6209)
                                local v94 = pu33[v92][vu3(6224)]
                                v76 = vu3(6209)
                                v79 = pu42()
                                pu45[v79] = v94
                                local v95 = pu33[v93]
                                v81 = v95[vu3(6207)]
                                v74 = pu33[v76]
                                v77 = v74
                                v68 = v57
                                v57 = v95
                                p52 = v74 and 4808128 or 15457463
                            end
                        elseif p52 < 4378156 then
                            pu43(v59)
                            pu43(v81)
                            pu43(v74)
                            local v96 = vu3(6209)
                            pu43(v69)
                            pu43(v79)
                            pu43(v66)
                            pu43(v72)
                            local v97 = vu3(6220)
                            local v98 = pu33[vu3(6240)]
                            pu43(v80)
                            local v99 = vu3(6240)
                            local v100 = vu3(6230)
                            v81 = pu42()
                            local v101 = v98[v100]
                            v66 = pu42()
                            pu45[v66] = v101
                            v69 = pu33[v99][vu3(6224)]
                            v61 = 1
                            v78 = 1
                            v68 = pu33[v96][vu3(6208)]
                            v79 = pu33[v97][vu3(6214)]
                            v76 = pu42()
                            v74 = pu42()
                            pu45[v74] = 0
                            pu45[v81] = 2
                            pu45[v76] = {}
                            v64 = v78 < 0
                            v59 = v61 - v78
                            v56 = {}
                            v67 = 256
                            v72 = nil
                            v77 = 0
                            p52 = 9754910
                            v80 = nil
                        else
                            v57 = pu45[v66]
                            v68 = v57
                            p52 = 3967159
                        end
                    elseif p52 < 6108849 then
                        if p52 < 5026686 then
                            if p52 < 4774161 then
                                if p52 < 4730217 then
                                    if p52 < 4691837 then
                                        local v102 = vu3(6209)
                                        p52 = pu33[vu3(6232)]
                                        v73 = pu33[v102][vu3(6208)]
                                        v72 = pu45[p54[1] ]
                                        v80 = {
                                            v73(v72)
                                        }
                                        v57 = {
                                            pu34(v80)
                                        }
                                    else
                                        v66 = 2
                                        v69 = 1
                                        v72 = pu45[p54[1] ](v69, v66)
                                        v80 = 1
                                        v57 = v72 == v80
                                        v73 = v57
                                        p52 = v57 and 15831192 or 1519818
                                    end
                                else
                                    v57 = v58
                                    p52 = 6122540
                                end
                            elseif p52 < 4794716 then
                                v67 = 0
                                v59 = # v56
                                v61 = v59 == v67
                                p52 = v61 and 10935560 or 13655452
                            else
                                v76 = pu33[vu3(6209)]
                                v56 = vu3(6225)
                                v74 = v76[v56]
                                v77 = v74
                                p52 = 15457463
                            end
                        elseif p52 < 5941627 then
                            if p52 < 5657797 then
                                v73 = vu3(6250)
                                pu33[vu3(6239)](v73)
                                p52 = pu33[vu3(6242)]
                                v57 = {}
                            else
                                v73[pu45[p54[10] ] ] = pu45[p54[11] ]
                                v80 = {
                                    pu45[p54[12] ](v73)
                                }
                                p52 = pu33[vu3(6210)]
                                v57 = {
                                    pu34(v80)
                                }
                            end
                        elseif p52 < 6075810 then
                            v58 = v75[2] == pu45[v63]
                            p52 = 4773744
                        else
                            p52 = 12830959
                        end
                    elseif p52 < 6808796 then
                        if p52 < 6508534 then
                            if p52 < 6436150 then
                                if p52 < 6159854 then
                                    pu45[v80] = v57
                                    p52 = 13502050
                                else
                                    local v103 = pu33[vu3(6223)]
                                    v78 = vu3(6211)
                                    v67 = pu33[v78]
                                    v83 = v103(v67)
                                    pu33[vu3(6217)] = v83
                                    p52 = 6104330
                                end
                            else
                                v72 = 5
                                local v104 = (pu45[p54[2] ] * v72 + 26566663909457) % 35184372088832
                                v80 = 1
                                pu45[p54[2] ] = v104
                                v73 = pu45[p54[3] ]
                                v57 = v73 ~= v80
                                p52 = 10952496
                            end
                        elseif p52 < 6637190 then
                            v78 = pu42()
                            local v105 = vu3(6240)
                            pu45[v78] = v60
                            local v106 = pu33[v105][vu3(6224)](1, 100)
                            v64 = pu42()
                            pu45[v64] = v106
                            local v107 = pu45[v79](0, 255)
                            v71 = pu42()
                            pu45[v71] = v107
                            local v108 = pu45[v79](1, pu45[v64])
                            v70 = pu42()
                            pu45[v70] = v108
                            local v109 = pu45[v79]
                            local v110 = vu3(6223)
                            local v111 = v109(1, 2)
                            local v112 = vu3(6234)
                            local v113 = v111 == 1
                            v65 = pu42()
                            local v114 = vu3(6237)
                            pu45[v65] = v113
                            local v115 = pu33[v110]
                            local v116 = v61[vu3(6216)]
                            local v117 = v115(pu34({
                                pu45[v79](0, 10000)
                            }))
                            v82 = vu3(6234)
                            local v118 = v112 .. v117 .. v82
                            local v119 = vu3(6247)
                            local v120 = v116(v61, v114, v118)
                            v63 = pu42()
                            pu45[v63] = v120
                            v57 = pu33[v119]
                            v58 = pu50(4724305, {
                                v79,
                                v78,
                                v81,
                                v72,
                                v80,
                                v59,
                                v65,
                                v63,
                                v64,
                                v70,
                                v71,
                                v74
                            })
                            v75 = {
                                pu34({
                                    v57(v58)
                                })
                            }
                            p52 = pu45[v65] and 10179257 or 13439664
                        else
                            pu45[p54[2] ] = {}
                            v77 = 1
                            v69 = pu45[p54[3] ]
                            v57 = v80 % 35184372088832
                            pu45[p54[4] ] = v57
                            v66 = v80 % 255 + 2
                            local v121 = vu3(6220)
                            pu45[p54[5] ] = v66
                            v74 = pu33[v121][vu3(6219)](v73)
                            v76 = v77 < 0
                            v72[v80] = vu3(6228)
                            v81 = 1 - v77
                            v79 = v74
                            v68 = 150
                            p52 = 9245524
                        end
                    elseif p52 < 7600349 then
                        if p52 < 7598898 then
                            v72 = 2426725
                            v80 = vu3(6238)
                            v73 = 16256350 - v80 ^ v72
                            v57 = {
                                vu3(6235) / v73
                            }
                            p52 = pu33[vu3(6231)]
                        else
                            v83 = 1
                            v56 = (pu33[vu3(6220)][vu3(6249)](v73, v81) + pu45[p54[6] ]() + v68) % 256
                            v59 = v72[v80]
                            v62 = v56 + v83
                            v60 = v69[v62]
                            v61 = v59 .. v60
                            v72[v80] = v61
                            v68 = v56
                            p52 = 9245524
                        end
                    elseif p52 < 7705660 then
                        v80 = 1
                        v69 = pu45[p54[9] ]
                        v66 = 1
                        v68 = v66 < 0
                        v72 = v80 - v66
                        v73 = {}
                        p52 = 7808829
                    else
                        local v122 = not v68
                        v72 = v72 + v66
                        local v123 = v72 <= v69
                        if not v122 then
                            v123 = v122
                        end
                        local v124 = v69 <= v72
                        if not v68 then
                            v124 = v68
                        end
                        local v125 = v124 or v123
                        v79 = 11678473
                        if v125 then
                            v125 = v79
                        end
                        v80 = 5935945
                        p52 = v125 or v80
                    end
                elseif p52 < 12148360 then
                    if p52 < 9989517 then
                        if p52 < 9097290 then
                            if p52 < 8942849 then
                                if p52 < 8631718 then
                                    if p52 < 8559515 then
                                        v72 = pu45[p54[1] ]
                                        v73 = p53[1]
                                        v80 = p53[2]
                                        p52 = v72[v80] and 12753253 or 6788007
                                    else
                                        p52 = pu33[vu3(6221)]
                                        v57 = {}
                                    end
                                else
                                    v66 = pu42()
                                    v80 = pu42()
                                    local v126 = vu3(6220)
                                    pu45[v80] = true
                                    local v127 = pu33[v126][vu3(6204)]
                                    v69 = pu42()
                                    v72 = pu42()
                                    local v128 = pu49(11337659, {
                                        v66
                                    })
                                    local v129 = vu3(6247)
                                    pu45[v72] = v127
                                    pu45[v69] = pu46(5586609, {})
                                    pu45[v66] = false
                                    v68 = pu33[v129]
                                    v57 = v68(v128)
                                    v79 = v57
                                    v73 = p53
                                    p52 = v57 and 4400050 or 3967159
                                end
                            elseif p52 < 8945052 then
                                v80 = pu45[p54[3] ]
                                v72 = 1
                                v73 = v80 ~= v72
                                p52 = v73 and 8953714 or 10952496
                            else
                                local v130 = pu45[p54[3] ] % 32
                                local v131 = pu45[p54[4] ]
                                local v132 = pu45[p54[2] ]
                                v56 = pu45[p54[3] ] - v130
                                v61 = 32
                                v76 = v56 / v61
                                local v133 = v131(v132 / 2 ^ (13 - v76)) % 4294967296 / 2 ^ v130
                                v77 = 256
                                local v134 = pu45[p54[4] ](v133 % 1 * 4294967296) + pu45[p54[4] ](v133)
                                local v135 = v134 % 65536
                                local v136 = (v134 - v135) / 65536
                                local v137 = v135 % 256
                                local v138 = (v135 - v137) / 256
                                local v139 = v136 % 256
                                v81 = {
                                    v137,
                                    v138,
                                    v139,
                                    (v136 - v139) / v77
                                }
                                pu45[p54[1] ] = v81
                                v66 = nil
                                v68 = nil
                                v69 = nil
                                v72 = nil
                                v73 = nil
                                v74 = nil
                                v79 = nil
                                p52 = 4688424
                                v80 = nil
                            end
                        elseif p52 < 9425345 then
                            if p52 < 9267242 then
                                local v140 = not v76
                                v81 = v81 + v77
                                local v141 = v81 <= v74
                                if not v140 then
                                    v141 = v140
                                end
                                local v142 = v74 <= v81
                                if not v76 then
                                    v142 = v76
                                end
                                local v143 = v142 or v141
                                v56 = 7599755
                                if v143 then
                                    v143 = v56
                                end
                                p52 = v143 or 15077588
                            else
                                pu45[v80] = v60
                                p52 = pu45[v80] and 406269 or 11297221
                            end
                        elseif p52 < 9717812 then
                            v72 = 0
                            local v144 = pu33[vu3(6239)]
                            v80 = pu45[p54[8] ]
                            v73 = v144(v80, v72)
                            p52 = 7611286
                        else
                            v59 = v59 + v78
                            local v145 = not v64
                            local v146 = v59 <= v67
                            if not v145 then
                                v146 = v145
                            end
                            local v147 = v67 <= v59
                            if not v64 then
                                v147 = v64
                            end
                            local v148 = v147 or v146
                            v71 = 811748
                            if v148 then
                                v148 = v71
                            end
                            v61 = 2324334
                            p52 = v148 or v61
                        end
                    elseif p52 < 11310867 then
                        if p52 < 10941107 then
                            if p52 < 10674695 then
                                if p52 < 10334306 then
                                    v57 = pu45[v80]
                                    v58 = v57
                                    p52 = v57 and 15065551 or 6122540
                                else
                                    p52 = 455950 or 16053418
                                end
                            else
                                v75 = vu3(6227)
                                local v149 = pu42()
                                pu45[v149] = {}
                                local v150 = vu3(6213)
                                v71 = {}
                                local v151 = pu42()
                                pu45[v151] = pu41(12075998, {
                                    v149,
                                    v74,
                                    v81,
                                    v66
                                })
                                v65 = vu3(6245)
                                local v152 = pu42()
                                local v153 = vu3(6212)
                                pu45[v152] = {}
                                local v154 = pu33[v150]
                                v63 = pu45[v152]
                                v70 = {
                                    [v65] = v63,
                                    [v75] = nil
                                }
                                pu43(v66)
                                v64 = v154(v71, v70)
                                v67 = pu49(8505744, {
                                    v152,
                                    v149,
                                    v76,
                                    v74,
                                    v81,
                                    v151
                                })
                                v77 = 20909468640776
                                v59 = pu43(v149)
                                v76 = pu43(v76)
                                pu43(v74)
                                v78 = pu43(v152)
                                pu43(v81)
                                p52 = pu33[vu3(6206)]
                                v61 = pu43(v151)
                                local v155 = pu33[vu3(6205)]
                                v68 = pu33[v153]
                                v81 = vu3(6244)
                                local v156 = v64[v67(v81, v77)]
                                v74 = v68[vu3(6243)]
                                v79 = {
                                    v74(v68, v156)
                                }
                                v66 = v155(pu34(v79))
                                v69 = v66()
                                v56 = nil
                                v57 = {}
                                v72 = nil
                                v80 = nil
                            end
                        elseif p52 < 11150923 then
                            v72 = 152
                            v73 = pu45[p54[3] ] * v72
                            v80 = 257
                            v57 = v73 % v80
                            pu45[p54[3] ] = v57
                            p52 = 8942962
                        else
                            p52 = 16053418
                        end
                    elseif p52 < 11634350 then
                        if p52 < 11472059 then
                            pu45[p54[1] ] = true
                            p52 = pu33[vu3(6233)]
                            v57 = {}
                        else
                            v60 = pu45[v80]
                            v62 = v60
                            p52 = v60 and 1835787 or 9374657
                        end
                    elseif p52 < 11954826 then
                        v74 = 255
                        v79 = pu45[p54[1] ](0, v74)
                        v73[v72] = v79
                        p52 = 7808829
                        v80 = nil
                    else
                        v57 = # pu45[p54[1] ]
                        v73 = 0
                        p52 = v57 == v73 and 6504076 or 4688424
                    end
                elseif p52 < 13795025 then
                    if p52 < 12966698 then
                        if p52 < 12733688 then
                            if p52 < 12619468 then
                                if p52 < 12173246 then
                                    v58 = v75[1]
                                    v82 = v58
                                    p52 = 13540875
                                else
                                    v72 = 1718314
                                    v80 = vu3(6229)
                                    v73 = 14553952 - v80 ^ v72
                                    v57 = {
                                        vu3(6218) / v73
                                    }
                                    p52 = pu33[vu3(6236)]
                                end
                            else
                                local v157 = vu3(6247)
                                local v158 = pu33[vu3(6241)]
                                local v159 = pu45[p54[4] ]
                                v74 = pu41(12275776, {})
                                local v160 = pu33[vu3(6223)]
                                v79 = 2
                                v68 = {
                                    pu34({
                                        pu33[v157](v74)
                                    })
                                }
                                v66 = v68[v79]
                                v69 = v160(v66)
                                v72 = vu3(6237)
                                v73 = v158(pu34({
                                    v159(v69, v72)()
                                }))
                                v57 = pu45[p54[5] ]
                                v80 = v57
                                p52 = v57 and 13839259 or 13978744
                            end
                        elseif p52 < 12820579 then
                            p52 = 16267830
                        else
                            p52 = 2438885 or 38236
                        end
                    elseif p52 < 13506510 then
                        if p52 < 13487691 then
                            v58 = pu45[v80]
                            v82 = v58
                            p52 = v58 and 12173130 or 13540875
                        else
                            v63 = pu43(v63)
                            v78 = pu43(v78)
                            v64 = pu43(v64)
                            v71 = pu43(v71)
                            v70 = pu43(v70)
                            v65 = pu43(v65)
                            v75 = nil
                            p52 = 2297326
                        end
                    elseif p52 < 13574230 then
                        pu45[v80] = v58
                        v77 = (v77 + v75[pu45[v70] + 1]) % 256
                        v76 = (v76 + pu45[v71]) % 256
                        v82 = v76
                        p52 = 13502050
                    else
                        v71 = 1
                        local v161 = v68(v56, (v69(1, # v56)))
                        v67 = pu45[v76]
                        v64 = v161 - v71
                        v78 = v79(v64)
                        v67[v161] = v78
                        v59 = nil
                        v61 = nil
                        p52 = 4776104
                    end
                elseif p52 < 15276027 then
                    if p52 < 14932100 then
                        if p52 < 14074324 then
                            if p52 < 13839275 then
                                v72 = pu45[p54[6] ]
                                v57 = v72 == v73
                                v80 = v57
                                p52 = 13978744
                            else
                                pu45[p54[5] ] = v57
                                v73 = nil
                                p52 = 3537746
                            end
                        else
                            v74 = pu42()
                            local v162 = pu49(7514395, {})
                            pu45[v74] = v57
                            local v163 = pu45[v79]
                            local v164 = vu3(6247)
                            local v165 = v163(3, 65)
                            v81 = pu42()
                            pu45[v81] = v165
                            v56 = {
                                pu34({
                                    pu33[v164](v162)
                                })
                            }
                            local v166 = vu3(6223)
                            v61 = v56[2]
                            local v167 = pu33[vu3(6241)](pu34({
                                pu45[v72](pu33[v166](v61), (vu3(6237)))()
                            }))
                            v59 = pu42()
                            pu45[v59] = v167
                            v62 = pu45[v81]
                            v57 = 1
                            v83 = 1
                            v67 = v83 < 0
                            v60 = v57 - v83
                            v76 = 0
                            v77 = 0
                            p52 = 2297326
                        end
                    elseif p52 < 15072368 then
                        v58 = v75[1] == false
                        v82 = p52
                        p52 = v58 and 5975785 or 4773744
                    else
                        v68 = nil
                        v69 = nil
                        v79 = nil
                        p52 = 16267830
                    end
                elseif p52 < 16016514 then
                    if p52 < 15641386 then
                        v57 = v74
                        p52 = v74 and 14318803 or 3005271
                    else
                        p52 = v57 and 12632627 or 3537746
                    end
                elseif p52 < 16170255 then
                    v62 = {
                        pu48(710913, {
                            v69
                        })()
                    }
                    p52 = pu33[vu3(6246)]
                    v57 = {
                        pu34(v62)
                    }
                else
                    p52 = pu33[vu3(6215)]
                    v57 = {
                        v80
                    }
                end
            end
            local _ = # p55
            return pu34(v57)
        end
        local function v172(pu169, pu170)
            local vu171 = pu47(pu170)
            return function(...)
                return pu44(pu169, {
                    ...
                }, pu170, vu171)
            end
        end
        local function v180(p173)
            for v174 = 1, # p173 do
                pu51[p173[v174] ] = pu51[p173[v174] ] + 1
            end
            if not pu35 then
                return pu36({}, {
                    [vu3(6248)] = pu40,
                    [vu3(6245)] = p173,
                    [vu3(6222)] = function()
                        return 3868919
                    end
                })
            end
            local v175 = pu35(true)
            local v176 = pu37(v175)
            local v177 = vu3(6245)
            local v178 = vu3(6248)
            local v179 = pu40
            v176[vu3(6222)] = function()
                return 3868919
            end
            v176[v178] = v179
            v176[v177] = p173
            return v175
        end
        local function v187(p181)
            local v182 = p181[1]
            local v183 = 1
            while v182 do
                local v184 = pu51
                local v185 = pu51[v182] - 1
                v183 = 1 + v183
                v184[v182] = v185
                if pu51[v182] == 0 then
                    local v186 = pu51
                    pu45[v182] = nil
                    v186[v182] = nil
                end
                v182 = p181[v183]
            end
        end
        local function v190(p188)
            pu51[p188] = pu51[p188] - 1
            if pu51[p188] == 0 then
                local v189 = pu51
                pu45[p188] = nil
                v189[p188] = nil
            end
        end
        local function _()
            pu39 = pu39 + 1
            pu51[pu39] = 1
            return pu39
        end
        local function _(pu191, pu192)
            local vu193 = pu47(pu192)
            return function(p194, p195, p196, p197, p198)
                return pu44(pu191, {
                    p194,
                    p195,
                    p196,
                    p197,
                    p198
                }, pu192, vu193)
            end
        end
        local _ = {}
        local _ = v190
        local function _(pu199, pu200)
            local vu201 = pu47(pu200)
            return function(p202, p203)
                return pu44(pu199, {
                    p202,
                    p203
                }, pu200, vu201)
            end
        end
        local function _(pu204, pu205)
            local vu206 = pu47(pu205)
            return function(p207, p208, p209, p210)
                return pu44(pu204, {
                    p207,
                    p208,
                    p209,
                    p210
                }, pu205, vu206)
            end
        end
        local _ = v187
        local function _(pu211, pu212)
            local vu213 = pu47(pu212)
            return function(p214, p215, p216)
                return pu44(pu211, {
                    p214,
                    p215,
                    p216
                }, pu212, vu213)
            end
        end
        local _ = {}
        local function _(pu217, pu218)
            local vu219 = pu47(pu218)
            return function()
                return pu44(pu217, {}, pu218, vu219)
            end
        end
        local _ = 0
        local _ = v180
        local _ = v168
        return v172(8937667, {})(pu34(p38))
    end)(getfenv and getfenv() or _ENV, unpack or table[vu3(6225)], newproxy, setmetatable, getmetatable, select, {
        ...
    })
end)(...)
