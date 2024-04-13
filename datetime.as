
#ifndef __datetime__
#define __datetime__

#module
// �����`�̓����������P�������܂��B
#defcfunc toNonFormatedDatetime str p1
    datetime = p1

    // �����\�L��Z���\�L�ɒu�������i���j
    bf = "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    af = "Jan",     "Feb",      "Mar",   "Apr",   "May", "Jun",  "Jul",  "Aug",    "Sep",       "Oct",     "Nov",      "Dec"
    repeat length(bf)
        strrep datetime, bf.cnt, af.cnt
    loop

    // �����\�L��Z���\�L�ɒu�������i�j���j
    bf = "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    af = "Mon",    "Tue",     "Wed",       "Thu",      "Fri",    "Sat",      "Sun"
    repeat length(bf)
        strrep datetime, bf.cnt, af.cnt
    loop

    // �j�����폜
    weekdayStr = "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    foreach weekdayStr
        strrep datetime, weekdayStr.cnt, ""
    loop

    // �^�C���]�[����������폜�i�Ƃ肠�����悭������̂���...�j
    timeZoneStr = "UTC", "JST", "MST", "GMT"
    foreach timeZoneStr
        strrep datetime, timeZoneStr.cnt, ""
    loop
    
    // �s�v�ȕ������󔒂ɒu������
    delStr = ",", "/", ":"
    foreach delStr
        strrep datetime, delStr.cnt, " "
    loop

    // 1���������[������
    bf =  " 1 ",  " 2 ",  " 3 ",  " 4 ",  " 5 ",  " 6 ",  " 7 ",  " 8 ",  " 9 "
    af = " 01 ", " 02 ", " 03 ", " 04 ", " 05 ", " 06 ", " 07 ", " 08 ", " 09 "
    nonFormatString = " " + nonFormatString + " "
    repeat length(bf)
        strrep datetime, bf.cnt, af.cnt
    loop

    // �A���󕶎��̍폜
    repeat strlen(datetime)
        m = datetime
        strrep datetime, "  ", " "
        if m == datetime : break
    loop

    // �g����
    datetime = strtrim(datetime, 0, ' ')

    return datetime

#global

#module
// �P��������������������w�肵���t�H�[�}�b�g�Ƃ��ĉ��߂��AYYYY-MM-DD hh:mm:ss �`���ŕԂ��܂��B
// ���s�����ꍇ�͋󕶎���Ԃ��܂��B
// p1 ...�����`������
// p2 ...�t�H�[�}�b�g
#defcfunc toDatetimeStrFormat str p1, str p2
    datetime = p1
    format = p2

    // �������`�F�b�N
    if strlen(datetime) < strlen(format) : return ""

    // �󔒂̏ꏊ�ɐ��������邩�`�F�b�N �� ����ꍇ�̓G���[�Ƃ���
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

    // �e�p�[�c�̏ꏊ���擾
    YYYY = int(getFormatPinpoint(datetime, format, "YYYY"))
    Mon  = getFormatPinpoint(datetime, format, "Mon")
    MM   = int(getFormatPinpoint(datetime, format, "MM"))
    DD   = int(getFormatPinpoint(datetime, format, "DD"))
    thh  = int(getFormatPinpoint(datetime, format, "hh"))
    tmm  = int(getFormatPinpoint(datetime, format, "mm"))
    tss  = int(getFormatPinpoint(datetime, format, "ss"))

    // �����p��\�L�̏ꍇ
    if Mon != "" {
        MonthStr = "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        repeat length(MonthStr)
            if Mon == MonthStr.cnt {
                MM = cnt + 1
                break
            }
        loop
    }

    // �s���ȓ��t�̏ꍇ�̓G���[�Ƃ���
    if MM != limit(MM, 1, 12) : return ""
    if DD != limit(DD, 1, 31) : return ""
    if thh != limit(thh, 0, 23) : return ""
    if tmm != limit(tmm, 0, 59) : return ""
    if tss != limit(tss, 0, 59) : return ""

    // YYYY-MM-DD hh:mm:ss �`���ŕԂ�
    return strf("%04d-%02d-%02d %02d:%02d:%02d", YYYY, MM, DD, thh, tmm, tss)

#global

#module
// �t�H�[�}�b�g������̎w��̏ꏊ�𕶎���Ƃ��Ď擾���܂��B
// p1 ...�����`������
// p2 ...�t�H�[�}�b�g
// p3 ...�p�[�c
#defcfunc getFormatPinpoint str p1, str p2, str p3
    datetime = p1
    format = p2
    part = p3

    // �Ώۂ̊J�n�ꏊ���擾
    st = instr(format, 0, part)

    // �t�H�[�}�b�g���Ƀp�[�c���Ȃ��ꍇ
    if st == -1 : return ""

    // �Ώۂ��擾
    target = strmid(datetime, st, strlen(part))

    return target
#global

#endif

#module
#defcfunc toFormatedDatetime str p1
    datetime = p1

    // �ȈՉ�
    datetime = toNonFormatedDatetime(datetime)

    // �t�H�[�}�b�g���`
    formats = "YYYY MM DD hh mm ss", "Mon DD hh mm ss YYYY", "Mon DD YYYY", "DD Mon YYYY", "DD Mon YYYY hh mm ss", "YYYY MM DD"

    // ���ׂẴt�H�[�}�b�g�ɑ΂��Đ��`������
    dimtype formatedTestDatetime, vartype("str")
    repeat length(formats)
        formatedTestDatetime.cnt = toDatetimeStrFormat(datetime, formats.cnt)
    loop

    // �ł��[���̐������Ȃ����̂����ʂƂ��ĕԂ��i�����Ȃ��Ƀq�b�g�������̂�D��j
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
