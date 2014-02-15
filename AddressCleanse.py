#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
# Author:      Casson
# Created:     17/11/2013
#-------------------------------------------------------------------------------
import copy
import csv
import re
#import numpy as np
#import scipy as sp
origstrt = ''

def main():

    # delete existing ExitsUnique.txt

    csvout = open(r't:\tmp\UniqueAdds.txt', 'w')
    csvout.close()

    # UniqueOut is file for all unique addresses

    unique = open(r't:\\tmp\\UniqueAdds.txt', 'a')
    uniqueout = csv.writer(unique, dialect='excel-tab')
    uniqueout.writerow(("apn", "strtno", "strt", "borocode", "incode"))

    # Home Base Enrollments

    get_data(filename=r't:\tmp\hbenrollments1.txt', incode='hb',
        outfile=r't:\\tmp\\hbenrollments2.txt',
        unique_file=uniqueout,
        cols = {'id':'N', 'strtno': 'ADDRESSNUMBER', 'strt':'ADDRESS', 'boro':'BOROUGH',
            'state':'', 'zip':'ZIP', 'apn':'APT'})

    # Evictions

    get_data(filename=r't:\tmp\Evictions1.txt', incode='p',
        outfile=r't:\\tmp\\evictions2.txt',
        unique_file=uniqueout,
        cols = {'id':'id', 'strtno': 'prem-strt-no', 'strt':'prem-strt', 'boro':'prem-boro',
            'state':'prem-state', 'zip':'prem-zip', 'apn':'prem-apn'})

    # Entrances and Exits. Street numbers and apartments in ADDRESS variable

    get_data(filename=r't:\tmp\EntExitAdds1.txt', incode='x',
        outfile=r't:\tmp\entrants2.txt',
        unique_file=uniqueout,
        cols = {'id':'id', 'strtno': '', 'strt':'EXIT_ADDRESS', 'boro':'EXIT_BOROUGH',
            'state':'EXIT_STATE', 'zip':'EXIT_ZIP', 'apn':''})

    get_data(filename=r't:\tmp\EntExitAdds1.txt', incode='e',
        outfile=r't:\tmp\exits2.csv',
        unique_file=uniqueout,
        cols = {'id':'id', 'strtno': '', 'strt':'PRIOR_ADDRESS', 'boro':'PRIOR_BOROUGH',
            'state':'PRIOR_STATE', 'zip':'PRIOR_ZIP', 'apn':''})

    unique.close()


def get_apn(strt):
    oldstrt = copy.copy(strt)
    apn = ''

    # house, private house, floor, basement

    apt = re.compile('((APT|ATP|AOT)[ .#]{0,3}([A-Z0-9- ]{1,4}))')
    apthash = re.compile('(A?#([ A-Z0-9-]{1,4}))$')
    basement = re.compile('((BASEMENT|BASE|BASMT|BSMT|BSMNT|BSMT APT)[ .]{0,4})$')
    numfloor = re.compile('([, #]{0,3}([1-9]|TOP) ?(ST|ND|RD|TH)? ?(FLO?O?R?|FLR)[ ,.]{0,3})$')
    floornum = re.compile('(,?(FLO?O?R?|FLR|FL)[ .]?([1-9])[ ,.]{0,3})$')
    home  = re.compile('( [#( ]+P[ .]?H[ .)]?|HOUSE?|P/HOUS?|PVTH)')

    try:
        mat = re.search(apt, strt)
        if mat:
            apn = mat.group(3)
            strt = re.sub(mat.group(1), ' ', strt)
            #print 'apt: {} --> {} :: {}'.format(oldstrt, apn, strt)
            return

        mat = re.search(apthash, strt)
        if mat:
            apn = mat.group(2)
            strt = re.sub(mat.group(1), ' ', strt)
            #print 'apthash: {} --> {} :: {}'.format(oldstrt, apn, strt)
            return

        mat = re.search(basement, strt)
        if mat:
            apn = 'BASEMENT'
            strt = re.sub(basement, ' ', strt)
            #print 'basement: {} --> {} :: {}'.format(oldstrt, apn, strt)
            return

        mat = re.search(floornum, strt)
        if mat:
            apn = 'FLOOR ' + mat.group(3)
            strt = re.sub(mat.group(1), '', strt)
            #print 'floornum: {} --> {} :: {}'.format(oldstrt, apn, strt)
            return

        mat = re.search(numfloor, strt)
        if mat:
            apn = 'FLOOR ' + mat.group(2)
            strt = re.sub(mat.group(1), '', strt)
            #print 'numfloor: {} --> {} :: {}'.format(oldstrt, apn, strt)
            return

        mat = re.search(home, strt)
        if mat:
            apn = 'HOUSE'
            strt = re.sub(home, '', strt)
            #print 'home: {} --> {} :: {}'.format(oldstrt, apn, strt)
            return

    finally:
        return apn, strt

def get_apn_at_end(strt):
    """Pull apartment number off end of the streetname."""

    oldstrt = copy.copy(strt)
    apn = ''
    aptnum = re.compile('(,? ([A-Z][- 0-9]{1,3}|[0-9]{1,2}[A-Z])[ ]{0,4})$')
    mat = re.search(aptnum, strt)
    if mat and mat.group(2) not in ('D','J','L','M','AVE','ST','RD','ROAD','PL',
        'DR','STR','SLIP','MALL','JOHN','LANE','PKW','VIEW','WALK'):
        apn = mat.group(2)
        strt = re.sub(mat.group(1), ' ', strt)
        #print 'Second aptnum: {} --> {} :: {}'.format(oldstrt, apn, strt)
    return apn, strt

def clean_apn(apn):
    apt = re.compile('(APT|UNIT|RM|ROOM|STORE|SUITE)[. #]?')
    basement = re.compile('(([1234]?BASE?MENT?2?|BASEM?T?|BASMN?T|BSME?N?T|BSMN?T|BSMT APT|BMT|CELLAR|BAMT)[ .]{0,4})$')
    numfloor = re.compile('([, #]{0,3}([1-9]|TOP) ?(ST|ND|RD|TH)? ?(FLO?O?R?|FLR)[ ,.]{0,3})$')
    floornum = re.compile('(,?(FLO?O?R?|FLR|FL)[ .]?([1-9])[ ,.]{0,3})$')
    ground = re.compile('(ST.LVL|GF|GRN?D.?FL?|GROUND)')

    oldapn = copy.copy(apn)

    apn = re.sub('  +', ' ', apn, count=10)       # Remove extra spaces
    apn = re.sub('(^ | $)', '', apn)              # Remove leading or trailing space
    apn = re.sub(apt, '', apn)
    apn = re.sub(basement, 'BASEMENT', apn)
    apn = re.sub(ground, 'FLOOR 1',apn)
    mat = re.search(floornum, apn)
    if mat:
        apn = 'FLOOR ' + mat.group(3)

    mat = re.search(numfloor, apn)
    if mat:
        apn = 'FLOOR ' + mat.group(2)

    if apn.find('FLOOR')==-1:
        apn = re.sub('[- ]', '', apn)

    apn = re.sub('(P[ ,.]?H[ ,.]?|PVT|PRV|PRIVATE)[ ./]?(HOUSE|HSE?|HOME|HOUSIE)?.*', 'HOUSE', apn)
    apn = re.sub('(1[ -]?(FLOOR|FL)[.]?|STLEV)', 'FLOOR 1', apn)
    apn = re.sub('(2[ -]?FLOOR)', 'FLOOR 2', apn)
    apn = re.sub('(FIRST|1ST|1RS|GNDFL)[ .]?(FLOOR?|PISO|FL[.]?)?.*', 'FLOOR 1', apn)
    apn = re.sub('LOWERLEVEL', 'BASEMENT', apn)
    apn = re.sub('(SECOND|2ND?)[ .]?(FLOOR?|PISO|FL[.]?).*', 'FLOOR 2', apn)
    apn = re.sub('[#;`]', '', apn)

    #if oldapn != apn:
    #    print 'clean_apn: {} -> {}'.format(oldapn, apn)
    return apn


def get_strtno(strt):
    strtno = ''
    strt = re.sub('[ ]{1,5}$', '', strt)                 # Remove trailing space

    streetnum = re.compile('(^\d{1,6}([_:-]\d{1,4})?)')
    mat = re.match(streetnum, strt)
    if mat:
        strtno = mat.group(1)
        strtno = re.sub(':', '-', strtno)
        strtno = re.sub('_', '-', strtno)
        strt = re.sub(mat.group(1), '', strt)
        #print strtno, ' ', strt, '(',mat.group(1),')'

    return strtno, strt

def remove_ordinals(strt):
    global origstrt

    strt = re.sub('(^ |  +| $)', '', strt)            # Remove unwated spaces
    # Remove ordinals on numbers before STREET or AVENUE
    ord1 = re.compile('(\d+) ?(TH|THE|RD|RDS|ST|ND)[ .]{0,3}(STREET|AVENUE|ROAD|PLACE)$')
    mat = re.search(ord1, strt)
    if mat:
        os = copy.copy(strt)
        strt = re.sub(ord1, ' '+mat.group(1)+' '+mat.group(3), strt)
        #print 'ord1: {} -> {}'.format(os, strt)

    # Remove ST etc in cases where it is clearly ordinal for number

    #ord2 = re.compile('^ ?(?:/d{1,3})([ .]{0,2}(ST|ND|RD|THE|TH|THST))(?:(AVE|RD|ROAD|PLA|ST| *))')
    #mat = re.match(ord2, strt)
    #if mat:
    #    so = copy.copy(strt)
    #    strt = sub(ord2, '', strt)
    #    print 'ord2: {} -> {}'.format(so, strt)

    # Remove TH at end of line
    strt = re.sub('(?<![A-Z])(TH|THE|THST)[ .]*$', ' ', strt)


    # Remove ordinal indicators, nd, rd, th from numbers
    ord3 = re.compile('(\d+) ?(ND|RD|TH|THE)[ .](.*)')
    ostrt = copy.copy(strt)
    mat = re.search(ord3, strt)
    if mat:
        strt = re.sub(ord3, mat.group(1)+' '+mat.group(3)+' ', strt)
        #print 'ord3: {} -> {}'.format(ostrt, strt)

    # Remove trailing RDs after numbers at end of line being missed
    ord4 = re.compile('(\d+) ?(RD) *$')
    ostrt = copy.copy(strt)
    mat = re.search(ord4, strt)
    if mat:
        strt = re.sub(ord4, mat.group(1), strt)
        #print 'ord4: {} -> {}'.format(ostrt, strt)

    strt = re.sub('(^ |  +| $)', ' ', strt)            # Remove unwated spaces
    #if ostrt != strt:
    #    print 'Ordinal: {} --> {}'.format(ostrt, strt)

    return strt

def clean_strt(strt):
    global origstrt

    apos = re.compile('\'S')
    aka = re.compile('((AKA|A/K/A).*)')
    strt = apos.sub('S', strt)                          # Remove apostrophe
    strt = aka.sub(' ', strt)                           # Remove AKA...
    strt = re.sub('  +', ' ', strt, count=10)       # Remove extra spaces
    strt = re.sub('(^ | $)', '', strt)              # Remove leading or trailing space
    strt = re.sub('[ .,\/#-()+]{1,5}$', '', strt)       # Remove trailing crud


    # If missing street type after direction and number assume its a street
    #mat = re.search('(^| )(WEST|W|EAST|E)[. ]*([0-9]{1,3})(?: *(ST|ND|RD|TH|THE))(:?[. ]*)$', strt)
    mat = re.search('(^ {0,3})(WEST|W|EAST|E|SOUTH)[. ]*(\d+)[. ]*$', strt)
    if mat:
        os = copy.copy(strt)
        strt = mat.group(2) + ' ' + mat.group(3) + ' STREET'
        #print 'Add street ({}): {} -> {} :: Groups: {}'.format(origstrt, os, strt, mat.groups())


    # Remove some spelled number streets
    strt = re.sub('(FIRST|ONE)(?: (AVENUE|STREET|ROAD))', '1', strt)
    strt = re.sub('(SECOND|TWO)(?: (AVENUE|STREET|ROAD))', '2', strt)
    strt = re.sub('(THIRD|THREE)(?: (AVENUE|STREET|ROAD))', '3', strt)
    strt = re.sub('(FORTH|FOUR)(?: (AVENUE|STREET|ROAD))', '4', strt)
    strt = re.sub('(FIFTH|FIVE)(?: (AVENUE|STREET|ROAD))', '5', strt)
    strt = re.sub('(SIXTH|SIX)(?: (AVENUE|STREET|ROAD))', '6', strt)
    strt = re.sub('(SEVENTH|SEVEN)(?: (AVENUE|STREET|ROAD))', '7', strt)
    strt = re.sub('(EIGHTH|EIGHT|EIGTH)(?: AVENUE|STREET|ROAD)', '8', strt)
    strt = re.sub('(NINTH|NINE)(?: (AVENUE|STREET|ROAD))', '9', strt)
    strt = re.sub('(TENTH|TEN)(?: (AVENUE|STREET|ROAD))', '10', strt)

    if re.search('(?<![A-Z])TH *$', strt):
        print 'still has TH: {} -> {}'.format(origstrt, strt)
    if re.search('(?<![A-Z])RD *$', strt):
        print 'still has RD: {} -> {}'.format(origstrt, strt)

    return strt


def clean_strtno(strtno, strt):
    oldstrtno = strtno
    oldstrt = strt
    dash = re.compile('(\d{1,4} ?-$)')
    beginnum = re.compile('^[ -]*([0-9]{1,3}) ')
    numonly = re.compile('^[ ]*\d{1,4}[ -]*$')
    twonums = re.compile('^ {0,5}(\d{1,3})[ ]{1,2}\d')
    dash = re.compile('(\d{1,4} ?-$)')

    strt = re.sub('(^ | $)', '', strt)          # Remove unwated spaces
    strt = re.sub('  +', ' ', strt)             # Remove unwated spaces

    # Cases where dash is still on strtno
    if re.search(dash, strtno):
        mat = re.search(beginnum, strt)
        if mat:
            strt = re.sub(beginnum, '', strt)
            strtno = strtno + mat.group(1)

    # Cases where dash is not on strtno, but it appears that extra digits are in strt
    # This covers case where there are two sets of numbers up front, dd dd Street

    notstrt = re.compile('^[ -]?(/d{1,3}) (?!(AVEN|STRE|PLAC|LANE|ROAD|PARK|BOUL))')
    if re.search(numonly, strtno):
        mat = re.search(twonums, strt)
        if mat:
            strt = re.sub(beginnum, '', strt)
            strtno = strtno + '-' + mat.group(1)
        else:
            # This covers case where number is not followed by STREET, AVENUE, ...
            mat = re.search(notstrt, strt)
            if mat:
                strt = re.sub(mat.group(1), '', strt)
                strtno = strtno + '-' + mat.group(1)

    # Cases where E or W follows strtno
    east = re.compile('([0-9]{1,4})([ _]|[_]{2})(EAST|E[.]?)')
    mat = re.search(east, strtno)
    if mat:
        strtno = mat.group(1)
        strt = 'EAST ' + strt

    west = re.compile('([0-9]{1,4})([ _]{1,2})(WEST|W[.]?)')
    mat = re.search(west, strtno)
    if mat:
        strtno = mat.group(1)
        strt = 'WEST ' + strt

    strt = re.sub('(^ | $)', '', strt)         # Remove unwated spaces
    strt = re.sub('  +', ' ', strt)            # Remove unwated spaces
    #if oldstrtno != strtno:
    #    print 'clean_strtno {}:{} -> {}:{}'.format(oldstrtno, oldstrt, strtno, strt)
    return strtno, strt

def expand_dir(strt):
    directions = dict(E='EAST ', W='WEST ', N='NORTH ', S='SOUTH ')
    direction = re.compile('(^| )((EAST|EA?|EASS?E?T|EASR|EASTT|E|WS?ESTy?|WE?|SOUTH|SO?|NORTH|NRTH|NTH|NO?)[ .-])')

    strt = re.sub('(^ | $)', '', strt)          # Remove unwated spaces
    strt = re.sub('  +', ' ', strt, count=10)   # Remove extra spaces

    # Some directions against numbers in addresses
    ostrt = copy.copy(strt)
    strt = re.sub('^E(?=\d)', 'EAST ', strt)
    strt = re.sub('^W(?=\d)', 'WEST ', strt)
    #if ostrt != strt:
    #    print 'expand_EWSpace: {} -> {}'.format(ostrt, strt)

    # Replace direction abbreviation with full spelling, E. -> East
    mat = direction.search(strt)
    if mat:
        os = copy.copy(strt)
        str = mat.group(2)[0]
        strt = re.sub(direction, directions[str], strt)

    # Take care of introduced anaomolies
    strt = re.sub('EAST EAST', 'EAST', strt)
    strt = re.sub('WEST WEST', 'WEST', strt)
    strt = re.sub('EAST(?=\d)', 'EAST ', strt)
    strt = re.sub('EAST(?=\d)', 'WEST ', strt)

    #if re.search('^E[. ]', strt):
    #    print 'expand_dir fail: {} -> {}'.format(ostrtrt, strt)
    #if re.search('^E\d', strt):
    #    print 'expand_dir ENN fail: {} -> {}'.format(ostrt, strt)
    #if re.search('^EAST\d', strt):
    #    print 'expand_dir ENN fail: {} -> {}'.format(ostrt, strt)

    strt = re.sub('(^| )N[. ]?W[. ]?', 'NORTHWEST', strt)
    return strt

def expand_strt(strt):
    oldstrt = copy.copy(strt)

    strt = re.sub('[ .,\/#-()+]+$', '', strt)       # Remove trailing crud

    strt = re.sub('  +', ' ', strt, count=10)       # Remove extra spaces
    strt = re.sub('(^ | $)', '', strt)              # Remove leading or trailing space
    avebeg = re.compile('^ *AVE?[., ]+')  # Avenue at beginning
    ave = re.compile('AVENUE|AVE?[., ]*$|AVNUE|AVE?NU?E?|ANVE')             # -> Avenue
    blvd = re.compile('( (BLVD|BLV)[ .,]{0,3})$')   # -> Boulevard
    ct = re.compile('( (CT)[ .,]{0,3})$')           # -> Court
    dr = re.compile('((DRIVE|DR)[ .,]{0,3}$)')      # -> Drive
    hwy = re.compile('(HWY|HW|HIGWY) *$')           # -> Highway
    lane = re.compile(' (LANE|LN) ?$')              # -> Lane
    mt = re.compile('^ ?MT[ .,] ')                  # -> Mount
    pkwy = re.compile('(PKWY|PKWAY|PKY|PWKY)')               # -> Parkway
    pl = re.compile(' PLC?E?[ .,]*$')               # -> Place
    rd = re.compile('([ A-Z0-9]*[A-Z0-24-9] )(RD[ .,$])')    # -> Road
    saint = re.compile('^ ?ST[ .,]')                # -> Saint
    st = re.compile('[^A-Z](STREET|STREEET|STR?EE?TT?|STRRET|STR?|ST|RDST|NDST)[ .,]{0,3}$')  # -> Street

    strt = re.sub('  +', ' ', strt, count=10)   # Remove extra spaces

    strt = avebeg.sub(' AVENUE ', strt)
    strt = ave.sub(' AVENUE ', strt)
    strt = blvd.sub(' BOULEVARD ', strt)
    strt = ct.sub(' COURT ', strt)
    strt = dr.sub(' DRIVE ', strt)
    strt = lane.sub(' LANE ', strt)
    strt = hwy.sub(' HIGHWAY ', strt)
    strt = mt.sub(' MOUNT ', strt)
    strt = pl.sub(' PLACE ', strt)
    strt = rd.sub(' ROAD ', strt)
    strt = saint.sub(' SAINT ', strt)
    strt = pkwy.sub(' PARKWAY ', strt)

    mat = rd.search(strt)
    if mat:
        strt = re.sub(rd, mat.group(1)+' ROAD', strt)   # -> Road

    mat = st.search(strt)
    if mat:
        strt = re.sub(st, ' STREET ', strt)         # -> Street
    strt = re.sub(' {2,10}', ' ', strt, count=10)   # Remove extra spaces

    # Remove ST from num when followed by STREET
    stst = re.compile('([0-9]+) ?(ST$|ST) (STREET)')
    mat = re.search(stst, strt)
    if mat:
        strt = re.sub(stst, mat.group(1)+' '+mat.group(3), strt)

    # Add street when address ends in ST
    mat = re.search('([0-9]{2,3})(ST)$', strt)
    if mat:
        strt = mat.group(1) + ' STREET'

    # Expand ending RD to ROAD, except where prior number is 3
    mat = re.search('([A-Z0-9]*[^3])(RD)[ .]*$', strt)
    if mat:
        strt = mat.group(1) + ' ROAD'
        #print 'matched RD {}'.format(strt)

    #if oldstrt != strt:
        #print '{} --> {}'.format(oldstrt, strt)
    return strt


def misc(strt):
    # Clean up various FDR abbreviations
    fdr = re.compile('F[. ]?D[. ]?R[. ]?')
    strt = re.sub(fdr, ' FDR ', strt)

    # Remove '.' after middle initials, e.g., Thomas S Boyland
    initial = re.compile('( ([A-Z])\. )')
    mat = initial.search(strt)
    if mat:
        strt = re.sub(mat.group(1), ' '+mat.group(2)+' ', strt)
        #print 'initial ', strt
    return strt

def get_data(filename=r't:\tmp\evictions.txt', incode='p',
        outfile=r't:\tmp\outfile.txt',
        cols = {'strtno': 'prem-strt-no', 'strt':'prem-strt', 'boro':'prem-boro',
        'state':'prem-state', 'zip':'prem-zip', 'apn':'prem-apn'},
        unique_file=r't:\tmp\uniquefile.txt'):
    """Get and process address data from csv file."""
    global origstrt

    print incode, ' ', filename

    outset = set()

    lst = list()

    # Open the input file

    csvfile = open(filename, 'r')
    r = csv.DictReader(csvfile, delimiter='\t')

    # Add standardized fields to secondary output file
    # Original file augmented with standardized addresses

    outfields = r.fieldnames
    for x in ("id2", "incode2", "apn2", "strtno2", "strt2", "borocode2"):
        outfields.append(x)
    csvout = open(outfile, 'w')
    out = csv.DictWriter(csvout, tuple(outfields), dialect='excel-tab')

    #print 'dict fieldnames', out.fieldnames
    strtchanges = set()
    for i,d in enumerate(r):
#        if i>10000:
#            print 'Stopping at 10,000'
#            break

        state = ''
        strtno = ''
        ident = d[cols['id']].upper()
        strt = d[cols['strt']].upper()
        if (d[cols['boro']]):
            boro = d[cols['boro']].upper()
        if cols['state'] != '':
            state = d[cols['state']].upper()
        zipcode = d[cols['zip']]

        if strt == '':
            continue
        oldstrt = strt
        origstrt = strt
        newstrt = ''

        # Apartments

        if cols['apn'] != '':
            apn = d[cols['apn']].upper()
        else:
            apn, strt = get_apn(strt)
        if apn=='':
            apn, strt = get_apn_at_end(strt)

        apn = clean_apn(apn)

        # Street numbers

        if cols['strtno'] != '':
            strtno = d[cols['strtno']].upper()
        else:
            strtno, strt = get_strtno(strt)
        strtno, strt = clean_strtno(strtno, strt)


        # Street names
        strt = expand_strt(strt)
        strt = misc(strt)
        strt = expand_dir(strt)
        strt = remove_ordinals(strt)
        strt = clean_strt(strt)
        strt = expand_dir(strt)     # Do a second time

        if strt != oldstrt:
            strtchanges.add(tuple((strtno, oldstrt, strt)))

        if re.search('BRON|BONX|BROXN|BX', boro):
            borocode = '2'
        elif re.search('MANH|NEW', boro):
            borocode = '1'
        elif re.search('BROO', boro):
            borocode = '3'
        elif re.search('QUEE|JAMA|ST[. ]{1,2}?ALB|OZO|FLUS|FAR', boro):
            borocode = '4'
        elif re.search('STAT|S[ .]?I[ .]?', boro):
            borocode = '5'
        else:
            borocode = '0'


        outset.add((apn, strtno, strt, borocode, incode))

        adict = d
        adict['id2'] = ident
        adict['incode2'] = incode
        adict['apn2'] = apn
        adict['strtno2'] = strtno
        adict['strt2'] = strt
        adict['borocode2'] = borocode

        out.writerow(adict)

    csvout.close()
    csvfile.close()

    # Output unique addresses
    unique_file.writerows(outset)


#    for pair in strtchanges:
#        print pair



if __name__ == '__main__':
    main()
