
#ifndef __datetime__
#define __datetime__

#module
// 未整形の日時文字列を単純化します。
#defcfunc toNonFormatedDatetime str p1
    datetime = p1

    // 長い表記を短い表記に置き換え（月）
    bf = "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    af = "Jan",     "Feb",      "Mar",   "Apr",   "May", "Jun",  "Jul",  "Aug",    "Sep",       "Oct",     "Nov",      "Dec"
    repeat length(bf)
        strrep datetime, bf.cnt, af.cnt
    loop

    // 長い表記を短い表記に置き換え（曜日）
    bf = "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    af = "Mon",    "Tue",     "Wed",       "Thu",      "Fri",    "Sat",      "Sun"
    repeat length(bf)
        strrep datetime, bf.cnt, af.cnt
    loop

    // 曜日を削除
    weekdayStr = "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    foreach weekdayStr
        strrep datetime, weekdayStr.cnt, ""
    loop

    // タイムゾーン文字列を削除（とりあえずよく見るものだけ...）
    timeZoneStr = "UTC", "JST", "MST", "GMT"
    foreach timeZoneStr
        strrep datetime, timeZoneStr.cnt, ""
    loop
    
    // 不要な文字を空白に置き換え
    delStr = ",", "/", ":"
    foreach delStr
        strrep datetime, delStr.cnt, " "
    loop

    // 1桁数字をゼロ埋め
    bf =  " 1 ",  " 2 ",  " 3 ",  " 4 ",  " 5 ",  " 6 ",  " 7 ",  " 8 ",  " 9 "
    af = " 01 ", " 02 ", " 03 ", " 04 ", " 05 ", " 06 ", " 07 ", " 08 ", " 09 "
    nonFormatString = " " + nonFormatString + " "
    repeat length(bf)
        strrep datetime, bf.cnt, af.cnt
    loop

    // 連続空文字の削除
    repeat strlen(datetime)
        m = datetime
        strrep datetime, "  ", " "
        if m == datetime : break
    loop

    // トリム
    datetime = strtrim(datetime, 0, ' ')

    return datetime

#global

#module
// 単純化した日時文字列を指定したフォーマットとして解釈し、YYYY-MM-DD hh:mm:ss 形式で返します。
// 失敗した場合は空文字を返します。
// p1 ...未整形文字列
// p2 ...フォーマット
#defcfunc toDatetimeStrFormat str p1, str p2
    datetime = p1
    format = p2

    // 文字数チェック
    if strlen(datetime) < strlen(format) : return ""

    // 空白の場所に数字があるかチェック → ある場合はエラーとする
    isOK = 1
    intStr = "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    repeat strlen(format)
        if strmid(format, cnt, 1) == " " {
            v = strmid(datetime, cnt, 1)
            repeat length(intStr)
                if v == intStr.cnt : isOK = 0
                if isOK == 0 : break
            loop
            if isOK == 0 : break
        }
    loop
    if isOK == 0 : return ""

    // 各パーツの場所を取得
    YYYY = int(getFormatPinpoint(datetime, format, "YYYY"))
    Mon  = getFormatPinpoint(datetime, format, "Mon")
    MM   = int(getFormatPinpoint(datetime, format, "MM"))
    DD   = int(getFormatPinpoint(datetime, format, "DD"))
    thh  = int(getFormatPinpoint(datetime, format, "hh"))
    tmm  = int(getFormatPinpoint(datetime, format, "mm"))
    tss  = int(getFormatPinpoint(datetime, format, "ss"))

    // 月が英語表記の場合
    if Mon != "" {
        MonthStr = "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        repeat length(MonthStr)
            if Mon == MonthStr.cnt {
                MM = cnt + 1
                break
            }
        loop
    }

    // 不正な日付の場合はエラーとする
    if MM != limit(MM, 1, 12) : return ""
    if DD != limit(DD, 1, 31) : return ""
    if thh != limit(thh, 0, 23) : return ""
    if tmm != limit(tmm, 0, 59) : return ""
    if tss != limit(tss, 0, 59) : return ""

    // YYYY-MM-DD hh:mm:ss 形式で返す
    return strf("%04d-%02d-%02d %02d:%02d:%02d", YYYY, MM, DD, thh, tmm, tss)

#global

#module
// フォーマット文字列の指定の場所を文字列として取得します。
// p1 ...未整形文字列
// p2 ...フォーマット
// p3 ...パーツ
#defcfunc getFormatPinpoint str p1, str p2, str p3
    datetime = p1
    format = p2
    part = p3

    // 対象の開始場所を取得
    st = instr(format, 0, part)

    // フォーマット内にパーツがない場合
    if st == -1 : return ""

    // 対象を取得
    target = strmid(datetime, st, strlen(part))

    return target
#global

#endif

#module
#defcfunc toFormatedDatetime str p1
    datetime = p1

    // 簡易化
    datetime = toNonFormatedDatetime(datetime)

    // フォーマットを定義
    formats = "YYYY MM DD hh mm ss", "Mon DD hh mm ss YYYY", "Mon DD YYYY", "DD Mon YYYY", "DD Mon YYYY hh mm ss", "YYYY MM DD"

    // すべてのフォーマットに対して整形を試す
    dimtype formatedTestDatetime, vartype("str")
    repeat length(formats)
        formatedTestDatetime.cnt = toDatetimeStrFormat(datetime, formats.cnt)
    loop

    // 最もゼロの数が少ないものを結果として返す（同じなら先にヒットしたものを優先）
    res = ""
    repeat length(formatedTestDatetime)
        rs = res
        ns = formatedTestDatetime.cnt
        strrep rs, "0", ""
        strrep ns, "0", ""
        if strlen(rs) == 0 || strlen(ns) > strlen(rs) : res = formatedTestDatetime.cnt
    loop

    return res

#global
