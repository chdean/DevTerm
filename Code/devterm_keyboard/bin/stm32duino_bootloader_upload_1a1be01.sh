#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1519979819"
MD5="5d2bdd1d6f101cc8b7d6037241dececd"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="stm32duino_bootloader_upload"
script="./flash.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="stm32duino_bootloader_upload"
filesizes="99811"
totalsize="99811"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="678"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    if test x"$accept" = xy; then
      echo "$licensetxt"
    else
      echo "$licensetxt" | more
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.3
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    fsize=`cat "$1" | wc -c | tr -d " "`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 300 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Fri Dec 17 11:54:44 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"stm32duino_bootloader_upload\" \\
    \"stm32duino_bootloader_upload_1a1be01.sh\" \\
    \"stm32duino_bootloader_upload\" \\
    \"./flash.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"stm32duino_bootloader_upload\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
	if ! shift 2; then MS_Help; exit 1; fi
	;;
    --cleanup-args)
    cleanupargs="$2"
    if ! shift 2; then MS_help; exit 1; fi
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 300 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 300; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (300 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� 
�a�]}w�F��_�SlEn��Ȗd[~		�Z�\
^n�9�ZZ�*�d�R��g�3�+�q�����li_fggv~3;���a�՟��D*k]���4뻏�m����{{�{�������M�>���Ný�4�f�i;�ݸ���
�y%��=��
��I4�p@]�Xk��'�������e��׳��6���\ �z��y*;�?�n�[�N�/E�W�����
�M�'ȬF��zYrdI��C��͵ux�Z�J�,KB�Sڨ�bC��	�1�=3�fM����q�?�p����yl�s���]����X
1|)�0W8�
7ً� �����N��g��a,+,`s��\��{	�z	a���>X�χ")�6Y?W]MR(DXs�����8Inf�������@�!Oٯ{��x���Ӄ�{�=g���V̪��z�vkg�vk�~b=���'�
�~�=���OD�n��8�
@,���٠&8�1Q��D
?��,D<�r��d��<��j��CEAb�	�Bƾ�4��"�^k�	�F��@�@�V���C��L�&"I��K� B$B6�)�ͱ�!�ãϋB��"��T�ԍg�FUay�
���l}M3}���`7 s�|���K��;s'�\���(�L �Yl{� ���f��ES�gJȼ������PϱĘ�E��H+JA�`�R��iL��x<�Q]@��3g����,�l�LD�@V
f��e>� d�Q,�s�FY��Z��Z�vd�1p��YC�y��W�a1��@���PP��^?f���XNe�h����¸J�;Y�{7�^�W���[����V�߯��닣MŻ<>B���q��&5���t
��iF�������2��:2*Xw���k������<~�|���{�6YuV���YV�X��d��
b-L ͐jd�
��C�F�j��i����iMO�b�6�}۬�t�\��TK��	��	�' ��&��8�I�4=���^0�rA�����M-1�W�ʏ`)o)�`N'I,Q���}��Gl���n·s��@"UX���j=�邹Q�?��c\bN�x���?�Ƈ<
�ԛ�p���$T.��/~������?dL����D+��=~����3��YAt��4����cR�dE�'OΨ��	�>.�H�ͬ��X��ɳA��	`���l��Th}T���IX�k�H�$=>�F=���n&�b�D���n�2Z�	/l�vk1�+-?"��:�E���{��>e�� @�WO
2���,�T_Asd��`�lY������fQ�e��c1�_hm���z�d��ɲy����ld,(��')���T.�S��%��� s��˄����c`F�a��j4 k����d����"8]A��ET� �"��^�A�#�V@@Qq5`8��*��0&� g�����.X���0�y��{���}��I�;e��1��0���{z�X���.�8��)9$���Cu@��ҵ����U�������9>���P��ی�M@9,���P��[Ny����s<�n��V�����R����?�m����+����_�A�8`'�퉄q�t�oD�����<X���F��7E)�	��zdI�B7V�r����?�<����.��sm����ߝ��m?���Z����F���ߒ����7�0�����n�ȃ�D 
��d{�p���Çۻ8h+`՗���վ]eّ�,����b���۷��?�Ÿ�;�=v���Z��y��BC�'��tl�-�9r�{,�}XT�"W;	��I��:��*'xN��9�	���r�@0�-C� Z/��4-�����
�n�B��f+�@PoG���D����"5@�)�i����S�yL�fT�������M�e�X�:�隴�����6�2����
�~�d�1�o��v��=(F��9
��}��ī�(�b�wM�X�*�$��b 
}!4�Ҽa?��m�m�ē�AB����I�I6':�ڒ�,D�>P�P&T1�s�~kèlm���wAx�����D?��@Ԏ��Q!��̱0w'��)�d�~͘Kh=]�n���QyX~�1�G�.�TMD�T!�;1Ć�e���s�B��L��(�t���	�u���A�]̅KQy� �������=,ۀ���ת،�73�����'�2����U�P�W�LͰyt9�Y��h��$�**�f�_�B]��&�.e�"_�;^K��
�
DȄ�5t
;�]���0�� +8K̙��u1?k�
�U�I��Y��Q}�YQ}�ut��/Z.8�ٿ�w���D�nߐ�zj�
	�ת�+V�|��$��ԣ��ʅ&��T�G�.�z�	Á��p.0p.�������^D���6�j��~����%]^r�(Aq/�(F?&�Xz���?�H�˳�|�.���^i[]n
�BHF;u��"_ܢ�i�e��i���zeD��V��6V�(���:���'R.��/*����w�Ǒp�eR�藪���c�HZ7p����G�⼲�H�Z9�	�Z��.�	��+8d�\�Y{I�)�)�q��Dj��9!��X=���� ����O1B�����ڂ��J���!7�ȚGr�8|~��K�����xI�)t����b0�sc��5d�xK� ��讔��2r���#��=$�!��Wr���_�U�d��k�����c͔�J��_6|����m�{x�P�kI�$�@z�Ts�w��(s��S�VBZ±�e����!�a׽�������{�Ki�c
M������6� )�8�:�����EB&:N���&3!�'��-G��4��]��2�BݸB~<<9�,���<e��~�X�lp�����
�/�3��/D�^v&/n��wq�(���A���ؖ9�W�ojLCe;;F� �%m���L��0BHy��h�th
 �x��D�*���)D]�94S#)
ȒC,X��p�|�������`=RG�ʋ6N�H�1���,"DW�+)� C
^�'Dt �}F�%)� �J� T�ƌ�H`QJ^��-�j0h���265���X�S���[��g���-�~-uy������!�cTp�\${KqqvZ=�N���~J78|�4b@�G#CA.Z�r���5�K�P0Dp�3�ۢ�hJAU�Q�9�+�nr�)$����@	�r���XE���������+>��pH:+5�d���?"���k4���.�D[�� �ܤ8KfE�tCc�4�`@���s���[�.�J7Q�����Hc�͐J�_tY�.�J�H��\Z��`����2�3j�9� 13���P��yma�h�Y�p[��t�P��KѺi�D��~(��G8��^="�r?�o�´qH��D��D�[Kt�v�U����P�8u����c6s�ֈ��"���o���<����W����>a�_l�˗~h��o1�ʿ`I��=����ȼ�������F�aS*T��d�$��{��M�\8{��0\���<N��+U5ӀW� w ,	}��?ZǞ�HSL /�؄�D���mR-3U�^�H�%����(�2��h��!v�^Mk���.I�9YG���÷�qNH��Ս#!��8t��jK�v�<�-3(�� ^�������N?]�r$pJ�jA�$T�UV���3���覼E�D׏�=�Y ��EL���2BnQ �K��e$&�3��;�]R��\�'�(��I��̴A�"�^;���(/ԇ�
4��td2�I���ƫ: �Gwfҍp�.���d2C�䖑@��4(%���G� �#�'@b��mQn��*?�IԊ��<���Y�no���m�F͠
_!�xC�v8�E$E{m�|KG�oP��rY���h���fɏ<;;�K�E����1C= a�~�ʛ<�H���J)@6t��@ra�7��D�S��q��@B'���ˠ��mS3
h�<�2KÍ
�	���_���RN$�
	�y��/H���Ӳ�eϰ�����V��0r��n8
�������y�?�]�2�`��g��cqvR�bq��V��6S�-�»�H�~g��&��������ƿ�ŀ���v�<��:Á�n2�(�3��]޽�,��y�*5	�.xN���m�ˊo�{���k0��EU�>�9������;S��X�g��muQ���b��{��orG�0û��.���+��ﱥX�3��v�UK�����R�¼aŅ�
gR��7�^ٿ�q����Q����I݇�Ͻu�`�¬�U7������%�uJ�Rpۋ��즴���@���p�9��֡�u��"t\�����@�|�v���Ϸ�pW���/o�c��G{&��?T��N�_
HA��q�q {�^�;���a���q�V���������h��k�w�������Ң������Wo|@~'���=���G�-�X���O���nqq���7����r����t�Tm��~�����n/�;qֱ^��z�w�Q.
*�!&�B�4�U�H��e6[�6'���au8�N��w�\� I�h��'�)TX����G��1Zv�W(�ح �����O����&>a������4jhMl .^�?io��o���������߈����6u¦N�ԉ��]��@{��]����F������lL��
9�eO�X��w�#�֌�R�$i�c��k|��ϭW�h?q�f�:�=Yr����=�Rc�0~|}�7����ujJ���w��AM)ҡ�=�K^%k5���O!d�^�=0.�^k�6~.F�X)��W�����=f���"���K���lάS��Z�%gh�}�ߢ�h����:���=����?���ؙ��Y��� �w����z�[��?�����'�hx6����/3�gD������rm��'�"�Ќ+�N)�� �#���:���N�9�P��*I���>��*uM�au�i�^�s��?�+�a]Z��)���&�����w�Bϻknz� B+pip��=q��P�B	�0��j�0T�EE"�핟��[9u�*G����l�w�wj��g��x�1s���uD����B?�a������aD��� ���q ������L��O��K���3�z$�����e�R�H���RyԊ3��h�Z���yi�]�4g+��X���<�T��`�L�U�ƕ\>:�*���.I��-�����䵫-T��_��X&��/��l�s���C"E|d>E:/�r�$^�{�4YXf ?�XP��p�멍�A��K��n��ʥ~���d:�2}�u��Y��uh���$S�$�KLl�6��s����f�G����f�g�1�����A�, ����A@,� 3� �?<�$�{������4������W��@��4"��to������:�C*d���bZ9O��ۮ�ղ�gĽ�Tld�\��u��T�U0΂�荷m�ǧ���:]�Ϝ`}����^)��"X�]�yn�����;��1��\�?�@!�T�P�D$p0  Q�hM$�?�������ߌ
��^7:����f���B�&*��'����ݦ����e�_cӂe
�;���"��m_QZ}D�%�ݣ�E��$�SO>L�^�"t�}́�[?�M�?�&�g`��DzC���xl�ʘ�k�1e&��:���g�q�
�H,H�	x�� P@*� �ο�� 8s���aA������bQ$� ���!x��_4�@h�|�����L��O��K���?������F����7����i��OP��k;Jt���mmT�$�(��77�\��|S\�
�f �b�����������m9$N����?!���{ح�� �m��rh939I��
{��[�õ����o��1�&�x�ڰh��J��ͽ
bd�f�F��豛�1?z��b���ޒ<e�M4����ʴ���Z�ɐl��Z�k:k��j�`/�|夞aC`�M����h���u�ȱ<��î�5�8��
� ��Š�0	c�T
]	(
��n������2��������B�4��|���b  � c�s���z����'������г�G�L�/����b�= �yUi+��h�B&�������0	� D$�	 !P) ��`�9H$PqD;���l�z��0������<�g&�`,~������_F������L��O��K���?�y�����o ��32�OO����1�!�����4»��o��9�nrx�dL�j���Zeyb����=����y��Ƿ��i��׷��~Hw�~���&)�z�H
��ID<Dc(d4L�yO�D%�dh�`���?d��1J�����7=���P��=~x�Ǐ��
���i�v��?s��G���_��!�t�����vC6'����t�Y�i���>xj�u�g��VM,L�0Q$Ds��է9K����lKd�d����k����Z��8��D�?�Ғ���O�[(�<�R�)r̺|b���Y8��-ѱ��b�p 7�x�QL&�I�qs�?!#T�Pf&��Q"�F�*G� d�)�;�w�����e����������_ł���?��|i�f��O��?���� ���;���Z�?]OF	h��U�K�k,���E%5w+'����A\ù?YqŒ�VniQp=.wm��Y��ɔ��g��r���N��c6pe��.$���X�?*�#=�U��)^��k��]9��/3���x[�"i��-w]��؝&�h{��QV���Co�r*���c
��7x{3__q/H�ԐkP�}�XM~ګ��HN���C�uW����ˍ��L�6��2�W3����p��Ē �ת��}�yN!���"�!F�Q�� ���N/Q�jJ������_�
�����=xD���b��e1���w}�Si��q�����7�۷{漭G�o	�?���p�v��˘'�#�F<�$IK|x��/^��,DMA�},m?H39������P|L1[w�/[�^m �֫v�$?1K2մ(���V)���Η�'Weyr�X�M4�޿��!�vaN��H�Ӡ��i�O=@��EoVW����n�s��h�K�'=�s���?�sVh'���]%�OqX��Ѣ���	%��˕��6\6����{�4֜b}j�]����b���KQՋU�>
���[��I��d
O�	
 ht9�|����l]v���u�.�����bA����e `�U�!\g�ms�T��N����)�\%H�X��J���`M�[�`��Hg��n8p��#6�)��4M�N;��[1\��\��^�#=aG�
>���I��3~�{N��Q�45�!4~�Q��`�2��(��m��uD�J��P���Z�Qg٠����`^�4������]�Z����^뤋"��-���k����l?U;% X�d/^��*}+gl8D�1y��r�卑�ʹ��@o۱�m��ψ��X�@]�uώ����[mUb_^��eG���&h�\ނmdB~�"K�O��n��G�Jf�]9���ڴ��W�G3�\4���� �3�x�<F�<�E8���}����EI�p�:��F���J�b��g�l.�X`��ҽ#�r��X�ͯ�1B�xST-�"|(b�)z^�kه���Q�g��z� �E���>��Y�����5m�W�<���J��˕����Y���q��ɖmҀ��9�h�����;vK�[��?�D��FO��a�e7>�4 ѥG,��<0�2�B][T8���iS��U��D�\X��d`��ۑ��DZ��l,3�[�m��{֫YS~DF�;/��t�o3K7_.ȷ
m���!dPh�/�29~ؑ�I8m#!���r�?H�7���-�^��Qe�
t���^�* ]����ts�!f���\מ0�<pJs^�ޚ$�LQI�}C�)ňR�O.di���*8'c�\��ҫY�d�P�Ss�y��-�a؉!i���oK�]2��>��	-
Rה��ϳ�;�yJ�N�aC}{�:q(���Y�;.?��0WM~���5/M>;��mv�t�Ѥ� p���������ĘR���H�]��Z.��%���(�v/��+�tqV�� b�_���vKB��B�-��V�	MB*kl���9���8_E���!7�������u7�w��䅳"���Z��?@��T>�\_ck��tz��,%�Y�Xr�kQx�o�O�ZR���S��>�pֻ�1h2)]pԂ_r�����[U��C�v-k��Ljk>������(U���I�]Ҽrʐ��^�n�a���4�㇢�Yj�!�X�<��EU��wtu���}TrpMI2���"v�L��Y��I+�t)�<vi�]g�3����ڤ^1И�w?�'�Z]�y��/��~i�G�f0"�!��"��ӱN:��J}�n��c]�{�v
�������Xot�q���R��8���1w��y,m�yf����[�L�F�U)���^�1/x�D��9���2l�G���i�
"��"i�����]u!��_?e��Tg��$,s�B�����ek[�'[�
JE����W�7K��ꥲ�t�#^
8#�v5�gݯ�4���g��^��-K�(V�)t/�<Z�v�J��ލξjT_Ņ=�o�F�����H���K����ֻ��P�O��.��/��:� .�IE�%�:�W���Bmg	�Je��X�9�ӛ�첑�N�o�����#7�Σ�U|\gZ���'�x���`�u��3*iO���r�%;0��00G�VǆԱjSpk܍���`�w�y?�I��WU��֓��3�`��=��c���벲M�ֶ�w��kJ����X��tA�
�)˥Տ����g.9ϟɞ��ɸ}��e��ᑤ���{����I/�S�{]�$�֤�U��
.��(����'Kj9GZX.n��]��ԕ2A$N�r�yQ�د�g��%*ɱ[��u�<���;(�uM�H� I�H�a�DA��DD@f�iDr	�(T@�� (��d$g�s�V�9{�cϺ�{�?���뫮�����}o��<SA��L�-6���|	��w�,2(g��<ſ_7���f������1���s�ڥiJ��u�:q��i�Đ�1��ެ��j[u��M_�y��L�fÄ�b��?�M�F���i���D�v�G�Ѭ��wh��]��kF��(5�iɠ���G^q��|�7���I��^.
�x�f%
o��l�Y_;N1Y\a{���z��O���IL@,�ڟ�L����>'?5�
�jJ��.�����<�p�N�G����&��ڽ܈���ρ�ڑ��j�+�^% ���|�^�x���a�*Ԋ�nXn.j�"���H�©��"[���Bk�2�¬X���ª�G���;����9ں����~7B��v>�aB)c��If<�Z���ē����~>�4�`�'�`��y�ҹw6�ap�o���ֈ�S�'k�Z�B��ʉ�lx�Uw�ь��� ��AZ͔�$�}�������-h�Ăl_�Դ@$�[^׶|@��G8�m;���7cD-��p����b����c�/>���[���$�+���>���t[�2��V.�~C��=��%��~_G���{<(�=�w�o�Z����9��%��������K2ڞ3��d�Gk�T�����#���?��)�*�mPE�` BP�h�=l�W����A�l�?]��C����W����C�?(���t��%�?K�_��)�)�=��������v�7 ��Z�,�ċ7���j�e7q�����+c�Ornh�v�-8}�(�+�o[Nbͻ�����S�d��3�D���tj�)?{�L�?mGx�	_cXh�
`A��04F�(�"��^C���˟� ���/��?f8��A�`�0�������������߿�$��������Ϝ�s�M���&�������^'C.�*^'���me�Ԃˮ�I5��G(���Wq����G�/
  &���W ��*@�oP��<�Nj���`�������+�r���z�����o��`�p����gi�_�?����C��_����k�o��h s���5op�D1�R,�P�9��X�����+�?���q,��� �����|N|�b`���(Ś���!b�N��������v (�d(�@�v��v���h�<@��B�Z����<�����?�T� ��C�����,�U��_R������p���B���'Z|�Y���oܑ��px�+�����8��":��i�-*�`���&%��v��S`μ<���E�y�z��+��cgӫMR���>�sJ�6����s��zzu�}C�|14�=h��M�&�~��y}��Q�����f1X��Y/4?W�YE-V��
}�'"z���Nm��Q�D6��ɧ�v�f��Fm�.��٩��p�m�~:p5��[����bc��k�|yg���ĂC�>�[����F�)
��Vl\#c�|Qӂ���/����n���>�u���Ƭ��a�`��ZC;�M��D������rAS+��k�8�����Si���g���s4ן��"��<�]Ҙ� ��(U����z�Q3�SJ���fo�S������F_I��0l*��sd�F��E��
� K>�ƻȷ
2ܸ'ʮ+�r�y�O`R��Va�k�S���~5�f���s6C�v=�G%�k��+Bx̎�%�6i:�ܥ1,�ll�HZ�Q��m��	�I&3�΍��Hd���ѕ!������?T���w��lC�<0�����fո�uMI޹&�w��f��[y�W���3o�mi�g}A�!;�����%�=�yג�Z�\��iA�?>�Hl,���e�WK(�hMʹ��,M�>���Q�cZ:���>)����MD4s]���ؼ�/:���~⣙���cjm��>H���^��R���2�Nn|1�E1�M�s��x5�v3��(Ͼ�P��n$����^W0e/��)�8��v���!]mt9����EV?�Z]R������X��Ij5�������-$���8�x&�uO������=T<_��	��\,1�4�������9�	���~�e��C����C�xʢ�W�/�w���y�^[^�f�wQ����V�
��a~z��r��<�����)p�e�F���g�	��X]k�Vl|��|��$v��{��x�,+�R���A��!^�K�����
����V�'@[H��vz�N�J���58�"�������hԕ�S�^%�"Ј���Ȕ��0RA��o���RI#ק�g��²'�;��š�����0�pAi�Q�{�-/�ǡ����i���j�i�,���Z٪��#+�/^����9�NR�F���:O�wN�oF_�J⺊�����|#)f�F
���y���L<��R�
�t�A21��������e�ㄜ@S����
B�zSE���OU�Z���r$;��e)�{1�E�}��sl���$u�'�s5�����u*B5*>��5��ƭ!�]GR�aڹ1t2#���p�,&e�1g����N�~i���
��
�R�a��<���іŝ����ػ�q�)���S~��� �{<�>_ �\����Ԩ�_?ֿ\�VY�f�iҊ�JYB[�x����sۼ\�
��N�ۦ���p%�U-
6OA[?�q~$�
��.s��]�#�f�'��LR'u���p1���6e
�e�ז��5�K���/�B���!d��[
XR��"���CS��Te�4`��A?A*��}k��~�z!����<M�r�,������׾�1�d��X���RoM�q{W�?�6�����9xy8"'\W�+2]��aI�=�cP<#6�r))���	������qn
%e��q�o,�t�YDvn��
��j;7������|oB�0+t�\�T��������ۖ����Ѱ�B�18�փ7\��u/��x ��"<�8�~�[&�6�lW9�1�9XL-y�j���{��M<����`ZHڪm���G��{�-	�V`x�����-�{hm"�:�C�B�1�J�0YdX�!S{d��SU�,n�Ǘ��_5�nղ|T𬇯458���B�Vb�T��K��XجBdnSݕI��
wF�3ӥ��wO9u�)d��{�����P3��=A�����I�0U
!ڹt�_]�j߫�0
��M�6��������` 	G �r`��CP`�����������ӻ�l�=��Y����������"���~���B/T�r�u>�v2T9�l�Gp��#��{��q�sY�ǜ�Qm#O���t���L(ǧ�<�#�qw��ۈv��c/pn�&>�5I;�������x�sR�ͳ=�M]�G/Oi�߲EOp���ܕ�&�HؼV�#)%�+g��q�u"���@?�0� 2�f����p(з) \�8���`8��C�������_���3����>Ě��6��g�_��k�������u�����,�]�a`����A���/������{bIރ���D{�����Be�/=ʞ4*����)���/�>���wz�-��E�k���=n5{�"j���]V޴��1�:h��'�J
>y-<8x4ղa�ݧ�9��G�
�)���|��Hp<��A������ڗ�l�c�b�������1���3ǡx
�[��fk?� ����` 8��4G!`�������� �u�����/��#�еG�������C~���C��������/����'������9��+x��#�U�2���ߩ����Xl�^��}!�)��~���a{P�����0u�cH��μ���#�7�*���v̽�Xԁ/��B�1�o����Й��Ỿ�A���V�/��>P�Z�˶v�~ (��Ȥ���D	G}�����iQK��D�`c�n-�uZ����h���"Qf�k	�ZpG@�@���Mq0$�' ̀�����������_r����;?�7?�����������u�����,�U�AkI'�{�?�ZHX��_���W=��?:)�j�tn��#��CX��Q�+e�:���g��КK]�$�^�)�����H����z�V�THZ�e�A2l?� E<፵��Tۛ���ZSP���s7��{�u��hG
b���S_i͊�9�˴��L�5D֕W���ʉs�&N� ,]��,������I�sG��#�h������b�f��:_��]����ޙ6�s��u��U��YJ�Җ�x7b�X�����l��o�^Rr�T��o����[��v}�٧4ړ���O����{Q��B��D�F����xr�M��/��i��2z��}G
����A*���ǩMii�ɯz�`	� 7H΅�_��G��2�0�є|�8���!�����F7ᅶ�A7��h-BwQ����H��E�;I-�`]!h�^�pav	{)��R��t�Q�IΨ<
�]�G:��9��ZF+1%��Q�9b�/�]��'��]=-p��ZI�F0w�k^�<���]UN�ʙ&��������#'k<��.b����ivH�;��{�vT����\��~���M&���vLU}ƾf���Q�9S���-�ǜ�SU�zǫƅ����L������H�V��΋����&�h��1|�lb�r��
<Z�(�˓,V�~,��hmIWv���0������Wx�=�u��^Q�^�P���:�~�&�%�rD�
�(�Z��%p�z��	y�|C��Ѧ�#m1XU4��� �/p:c����Ӫh��w���R� ڲ%yF:�����h{��J�ܲ���W�ы{��0�1��#���k��)��>�V����w �rW�lٖ����˽�Oaq����/�;9���y��9j��WQ����[�I)��x�.��~�d�.'�_���s�pbe?7���-szw��u[3���+W35
\	�G2rK���4ئ�ժ��~���U��Hx���� �.�t������~t����qL�=�/���I?Z����<�JV�+
%����S�NU�XU� Nh�c��5����^=2���"�-��x�ʍ<�z�q�
��a��^��j9D�z4�fb��,T��-�Χ����ά$�.���eB��|)ɔg��߂�1V3S��W��k��t��oX*�{��0Crٗ�v|���U�
�	FL�����v/CŖy����U�Mp��b#���"��<���U�� ��ͤ�,�g�|��Y��e<�a�$�j�D��+�ܺ枠���kǒ1�cc�%�Y�{,���
��HzQ�
u�n�����:\,������m �h�Q��eCG�w�~|���=���t9���mT���sO���t�u4p��Sz�)��qT��L����%]Y�z93���R�������b�.��TR}��?�Kٔ���si�c3�CY��ߖa��ε6����A�i�Y$�FQ��G���2� �0{���#����گ�	�g�f�gi|��Ù�כM
�V�r����LǺGG�A}���{�FwŨ�=�P�X���~�o�����ߩՕ)��u �����Aj�S��E(���=2���T|�}��ɖ�9�F|Z�7��]��Ǽg=Oi���	�OJį�=�X��??Z2,��'�����u���
�h�
���ʨ�����*H���+�z
�!���>�6��}��͟���^u$�s���x�����{w^x3m��w�p���y˙�M��4�*%��X�}H��F�w�_Z�E�>��_��^���� �7B7����X�еe���ݷ1H���)`1
�䧛�Ӆ&*,"Uǆ�&��;�	�	���y�k�'�!m������O����㼂�{I�s��[�����>�]�wߡmM�\�M/ Wե?5&��\�]k�}�ؕ"��8�ѽ���eV��N�>��%;˿���H���o����9���'��Tzn���,b"�O��Jod�pA�DF��5,�Ƣ��k��ψ!��O��0>2��GTW����G�4ɿ�n%����]K���3y[��JJ�<�b�"ogc�>r��,B�B��E�*�Ŵ1lkc}�qxD��=t��8��H�����oj�q�^��f�l���s����9��/7�F��
�5�럂9U�{��H��L��@'�6r-:�����L���ϫ��I]�n�yF�U<I�˲>�5Ti��+.���})�w��<E����������&�ߎ&�âc�����sW� �P��[W��>+�I�\��P�����\h����ao��k��Z��q��a �@�:?pDy:Ƕ�u�C�*l�䰵���鉌lJp^����A�+����l837kS�Q��ޛ��ρ�_�����H\A��sf��f�-�ϨR�À�����RK�M�*I���=-.1�a.�L�����I�еo���^o�2>���z
9�h�3s<��Ʃ�+�zW���W}a�R�����zy���Su3����2��-K*�Z'aV�*��6�NX��E��~hV�ں�+Q� g��Lc����`?9��۹_nFJ=��'($17��/��"M\��ii��I���g�V���ɦ�ͮ C�S�[���w��?�p��d\��-s?�4;�E��y�������i������8�ʸ�wi"��:��.��p��YZe@�"�7+
����X�2� ��틽_�PȘѰ�U��Iccú�:��
����y��qt��~���]���o�U�4�$Hyj���$�N�ɪ1XP��:�Gқ^{��[
+����&�r��.��W[L<�c�vo6�u
����!*p(LE+�2C�!F�)�������������߱����p�"�`��ߒ�?K����a����|P��k�����C������xys�������LsTRD�:;:��PU�#T�B9��1�O��3
�W����U`*J��Q<�������?�����*+A~{��������9���o������������?�����A�����&��`8Yf�_A��yQ��E�������\�*Cñ��`��[��-;�ab�R����˶A&����9�]����
TJ���Nq�s NMc�8Pz.������"bW�
�]h�m~r���"�L�:~4�|�!�\%�'�2e�u���Q	�.�Z�O���f@�)��+3K-8���a?�i�E���Z���`%럲�͡�lI�:y���3m����q�Ph�c�y��>� ��Ͽ�o��a��v����J�*����F	��� qRB���(�����\	�����w�+Ba��[��gi�����D����������=�5ˡ��=�8S���6�R�g9��pSc
����qtt4(�U/��\8dEs�Ƿe,]��V���~�Q��=g�P#����x@�r�?#my'my˷(�ݮnF'U?�M�`�A�HO�VZ>�xȷ�.�E㜿#?O�a�Cn��f�Ɓ����C�C�`�޽�֑�p�I�>5�Ed�fWP�EA<�,ݬ��[iF�' �`��ȶ5ϡ�����aK���ʥ����Q��S� w�Z�EdG�?��p������h�P�᝔���X[��k��vL�cZY�=� g/����X�H3��*�����j�aϻ��i���Fi�;�gv<�c�_��q>�,ٯ"���e��z���
C���,Qr�u	ʗC�D���TI��nh��`�c�&nR�/(�G�b5��0 �qr ռ���Sb����\�g��6�튡�N���p�.��W�T9��+�̈́�l�R9���qe
�gj�f�^J�}�%3i$���i�X�uw��CaF@^'&��w����]x�)��~�M����-�'-��x���z��V /�S%+�e�!�����yK�D�(��o�s�4�c&�N
��|Zs�B�U�ulÓ����W�	�0O�
��ũ�7箻���o��=t�0g<�!���+�F�P{ka�7�����=/�G]#)�T��{@D���jD���
�a�@j
t��{�}E���K;�#�;�_2kf��GWE\��X1c�杘���D�}��ـͤ1���\���sm��=6Q\u�`�+�j���H��H	� ]�N		���N	����F�A����ϋu��}�}���o�9�Yk��Zk�̜M�hK$�^�v����~����;�]֚P�B~�~�!cn¼1Rp��'v�-c���Hu>�VG��>�(r�0AE�IS�S��w�3��I � c��r�q#¨�4���ڏ�X�j
��X&Λ�e
��Ʈ�ժuYso�&�6�[e��Q"W�n�b�ѝ
��#�l7[������ �E�;_=��d\�Ph;
{A�F�0�#FV�x�T���!�`# o==M?�*�3�̃������`�N�5��"�ի�F99+���Of�éݝ=�e���U�G>/l��|���ϼM��q�3�Aǈy��� 0<v�hf4p�n�Sa���?d�*�L���p;ɪG*I�uTn��TfeeY���ІD}�<�os��s��IK|g�ǲ��ckB�M�\Nv�:w3��>2k�k����vZhTkGE�#p<m��t�#6��ơz��Gw�'C����^�:U������'�|
��j�J�5�JK«rOD�;�ը�4,+�n��&�/�=�KC	W���b�ga���>���n<��)�: W���4��L�^�^4�>z3���r�]I�����G^��C�g�����}vܚ��e��s?�w�P~��۫Ǝ6�����ޒ���v�/m1r0�;.��e�a�q+���_+��a��;zf�bk8�b�^���X��M�򗌒�I�"�S��}Sҟ�RD�Ģ�i�﩯��������S�z=It��&h���������d��G[PH�O)=��}�z|���:�D�t{�l��̫�,} ��H9Q$lܮ�DW��0G�2����ҫǚ�������z1�gU��&W�Z�Z>���E�qu��Rv���<!U��Z?�d�5����g_	��t�R#��{��n�4�=i#H8�)w�/�7��m�A*o��3�zo�'f�)-}<� �v'���^K]�r%���0��g̝�qU�F�|��k_�*��t�(��>f,M���R20���j��[�d$K�(����k�Иg���GO}f�E[��x0O�c(���P[�젯$� �l(���sB���[�-�m��`����^K�������Ѐ.��ƈq����ј�N��^�`b��ᡙ?Q�ݪ�z+o�:��^���̓=|�3L�I��gm/��e�axp�ݚ#ҩ��$�nǤ�NʽM�fT���� �u{�=�iN�!U��h)A�fJ�T�M�t핁7pr�2����@�9M�{؜��{�:$�9���5*�Z��ExE�p=���g�:9)�ZR7��Qp��zx�Ll���Q)c�n���+���G^�4�F�j�&
�7k-AIvq���0D8Ι��0+�>M>5~ w��L�����j�������
g���?*M4<p���?�vh93Q��}\q��0x8vF��\�V��^ߔ%ɢO�.θ���&ڊ���OvI��O|e�r��'o����_��HƇ����~F)
�U�CdV{LU+��O��/޸L9ay��SV��{��>�+ģR�F@;ix�q����_��x�	�y�s4"y8�gd�-�=3�N�RUi����/q�wFefʎBZ$�tB���������;��1W!%.�?(��b�����M���98�7����`�8l��)�<�$o��@|��^��,S�Ȳ���mD�H�t�)��,�A�0ӷ2q8��7قJ&t��x,/7;��
�⤷�P�(cp���z��H�I�����K�ɚ�����M|��U����{.?4��z�u���-��%>��q����-��dT(��J.�i=�1� ����e(�����A�"��[��}ر�{?:�Э!�Ul~D�?�M��BGO3��e��#���Dh����%��U`fg,x�,nU뙫'
���}�y���Y�R -����s����e��*���22�Zt�V��?-���7�JV�!�͔��In���oE�Ýy\E����t"4��҇����+�S"��c8����c[����w��=v�	n7ܜA2;O�}����h�UY�ٶ���Ό��I�!:ű>BDE�G�ʄ�U���f����LS���_�X����}�
ݷ�c�H�6Ln�'��L����pL��<�{%�Xm���%}����ljf��C%�#k�^a,�3�)r�r$�|b�:l'\�WT'��8��>騠�pr��k�j��Z����V>��-�4&M"5Y#&������rp\��!ɘ�Q(��i�����[!�I^~�z��".\�[S�r�%G��h���-��I�a�����睗 �9?=)0x�S�­�,�#�lى���fF3��Q�E�<�<���TuN�a��,��"Ɲ��Wß�Ɖ�I��v��vsqP�L_�`��w��W���B5�5�G{f����#�܇*�x���x���e�ے�9�{g*�>�����2#�-�)
�=4�ǘ*:����k��m<���-����Ht8��ph���=��(Y�5i�ߨ�\��cN~
(�6�,>����u�aZ�xF���@�ˤ]�gh�:�f��W3�ތ�%���M�7�3Ƞi��<[(j9~��?��g%]�4	�1����Y�{����y�y�L������X_����^�(�� �]ӎ��r;Y���S�{_�U���QRR����p����8�Of�=���S\P���_��3����ˏ�߫���C��[;֮��l�����9�EU�:S�v�K]�4�s�/E��A[y�Yy`2�v�m%$�0�0����e�@7��Ds=/ʕ��%O�vR�`���|�V�(yC���sl1�ŷ�Xg���g��أU�1H-��JY�]R��G�LD�=sS���3�4����"�|�/�K��8h��o�af�6?�O.�$�9*��T?r^��9i�F.�������yS�~��R�K��
̇��>4Ќ��QIdi�)���o����_���7���S��f�a��H�
�ܟ��Zs2O2H��@�� �gz�����A�:@�}��-(���ͬlmL1��]�@ָ�!�g�,�5�@˒�Y�R:i�����R,�+�g}���LxL��O��Ҽ�>y�@�&�f��XM��Y�#]���Ҭ�ثvf�G�5�㌡Wo�q��k����������w�2�Ĺ=T��h�A�XXdE�� ��\=����ą>_,)�V�b�)9�9�85:�3��l����$�o�$	���"In���_�Q���� ��{�O��+^٘B�>y���F68�B��[�6��X=�KH8dp��h��C��<��	����Zkt=ڬF8cm}���!�u>8o;y[���V�F��2re��ƉE���u<�5�}���j��ñM�?�hpj�)�&��a���v-�g
�ٱӟtoYF�.<R!�}���˿�,�DbIRM��v�Ĺe�i���H��{��C+
B$'g�+0f�6����ʇTx&���t���׼���d��i�3�m<ۍ���?�S�!a���t����;(rCA�)����������Fp3��YYiS��Ȇ���6�m�<��q�9gb����+=�zVAm�"{d᯳e`�k����c5��kz�Z�fP�_���'���ϕ@v�Ϗ[�[ᓷ���o�l�d���L��bY#��(�f����TQ�Q�G"��{D�1Y���^Q�O�Gc���VQ�[A����ʗ�:�M��3�q����H�)�1���A��U_O4���(��ȳ���!�����0 �Q�e�֩A=�����L궉�n�Y�K5��҂In<	G�G�hђO��mH����˕�w�M��rU$�Q��n�ip̮��Q���4����xZ!�৙�E=)[����uz�r�&�!�������<$;����Ưf��w�L��ƃC��U�Ȓ*c�|�톧�r��x�X�v����~�gs�hP_�\L{�L7է�}4���޷�VN<�i��nֈ�y��> OƐђ�q�u�5��c��$�~-4K��'�(�~��x��xf��B�c��T��X���1�f��S�	����wb��j�
�oJ�����
�����\.�SW�)W9V]��t���C+e& A�[�8�`��_x�8�&	"	p*�-|'g7����2�`�X����Q��O�:�����^Hyc�����o[|���"��:��#��I�DD"i�~ޘ��C���-��!�8W���Hd�s���m&��ñ��rF`�g��MYTV����쪈D2N����m�(H���zr�C�ح�쒣�q��-M'g&J�ܢ{٦��Q�:��19�ߚb�z�G���2�j��4-��&힔�mM*��k/��Tb���i�t�/ʀ`L�����m��3D1^���@N��~�P�r ��'�"�l�#�h���x����n�u�<rЮ��:��%&��#�x��f��v�]�n��L���G�z�7����=���
�Q4jAG���2�@^	β[��-�7�.���M#��ɸ����5�	N�VZ����`�;(-/~*�[��%t����������i�%��CM�;̨��{e�����"�+3���ְ�C:V�(|����׌���F!%Ǽ}���;��۔�yp#{�Rr����ى)�fN
�H�C��vFO�oh܍�M��x邬�$���n�y����=�d�c��R&�JO�c�;P�S�XB��XQ�O�a�C�v�=Ъ�WӕX)d�)��;�����I�_���qCo��������;8٢��ܗ<B�
��Ljv��ST�q�*���Q��	�G�	�o1��m�%Z^�?0)
�4�6�o]X[�8�:�7^;�i�+,�5B�G�� ����ZuF�ns��ҭ�� }�\\W������Q����V��k*�񰰹˸���'�V&h���KM�8�<��0���iF�q�R�W$u���i��,�0+-�3�^���~��[��r�0�����2p>[���Lnm�V8 b3Bz�]��$�rԙ����߿�`���Kd�&g�d?yľ|�{��V�l���.
v[�?s�7[�k��S$���%�[6��KoHK����_4D�l(q�x����stş~�)�_,�ň{)&
�K-^\�O<��倕�BX�� y�&�2��w��U�
�5�
6�tz�ԫ>_���U���^���F���)�%��ͩ�f�>K�����U�8ޝ.ۨ
���u�1C�����b7�7����t!t�{��	�����oK�=,�B�4����|��B��?c^�����7kg�ۙF��p�<o��
��V�}������gc�2Eo�N��i.iA�ŗ�����m�(8���J�6���0�斬����%�JL�Q=#J*�(�"CG�7�]\�>Q�}�>ar3h����2�ߤT��f��wW�m�M���n��m�EÝl�<��Gr��&MC�����ԕ�jǛ޿h���U�H8�����B���ݤ��/^.R�{}���0w�z�f�hy�-�G��ٯ�Ǝ��|F���ג�Y��v�Y�0�ꌫ�g�U&�t�
`�GSf+�@�EA���$};�m7+IT}��3����Lbx�q��h�#SC:,]������"���O�C5-�ӣ�E��sb���~�}�>_�
�u0}:2X�����1�{�mQ�����3�N&�li��l������G�_���*��9[�湷��&�"����� ��<�D<�f9�]�wَp���
�?�m,�y\f�O��+�d�&�`�/}�_D�^���g9"�S�Xv�H�e�9�>o� �v��7��'�E�#�2�	�ficv��3�GE�$��+'v�
WN��>��`�g��Av��"r6]x� æMRۄ���Y4M0
oW��$f?�%U^z�S>���~��B�ȴ��l�j�U�Hs��DO{S@\^2�[����6�������I�Ҹ�!)���9��N�Ю��=d�F<���D2"Y�^�!IӓEQY�EjuZ+c}>��A�ʂ�e7��ƁH���dH��-<��#@���t�_�Nز:��W�dQ�#r�k{FuoO{"�[���Z'4���0�0��y��0ㆤV�w��̓��������ꏺ��Ğ�F�**�����iD�A&R�}�Qh�tZ�R���Y�̳;5�MO�d�x�
 �D���B�-w�Z���(H����RŅV��?oԘ80�C�^����ة9^��$;����¼&��þPy�ۻ�OD��&��\4Tǜf���%��{��M�*9�/7xm�{&k��f��}��w�y����N����9�9$WG�:�j���X���$#;=�gp�$��$5d`��2xʟ���F�a�+���}�����z�U���Sy�{�Z���)��A���Hhr�P���'/��l=��������'����3�����O�t�&��+�
��X�
j��RG�u�
�9�Q���
Di�����@�]i��o��#,j+��(����1:&��₭'�y�	m��V�ړ*��7����m�.������Icf�{.r�Q�iT��4Iu���δI�5,0Vy��V�`�XW�{UCI!���V�&�3|Ȱ�If^L7gL�ޭ͖ݙ*\�DS4���C(5���T6�!��o�x 2��&���	O�Ў� 7�X�-rXhMhu��ٞ{1t�aa�y0��=�A�݁�Q�?���
g�|���	�z�g7��Յ��d��d�3U��Й��gi�á҆����������+Ejr}.r�s6��3?@bZ��-N���Dڬ�NONy�W),Z�p��\�O���T����E�ƹ�v��ѩu���;!zDh��҇�X�u�GԻۚg ��K{\ush����
��L���T��>�ц!>d#��zL۩;S�4�4k3k��'��E@�?�*Q2T�.t:�;J�Y�}�=������RB"�k��x�-tVEc����ę�L��3_��HLQ��]j�7Ƒ�#��@�N�d&T��1�W�se��P���'5z���sr��s�:�١_����L�;��7Mxx�l��ǰ��l���]�.�w�/SVZ�8'�[(�9@S� �TG5e�?��>��B���R�:+κS��{�����^�դ����L��B�r�>=�̊a���<�ƅ����7i���ǁ��x9{�M��p����U`�{�̾���#F � @�_(���6o{VVym����y�u��}6SmZ9ɍxWzN/!q����9�I��y�b����ec�d�PD�����^Ġ.~QF��D)U�\z�t�{���)60S&��򩮔+xN���� ��[8+�`�
ݳp��7U�#/D׭�t���
��9��B���Z!�#'����g�\��|z�O��
��<O�Rڋ���,�3�@`Q<���*p#'�]iޛ;�#�9ٿ ���Լ����!21<�$��lў3ݾ}Dq�cP��N��a���ӟ ��X>�b���|��t�D�>�z���4A�OG���TUc+���WN�]�����*`�8�5uE�߫@&��c�B
yX<�� av��&N���u9���%�ȓ��T����:�������N��=���2�V�~�k��֫�@�2�3%\嵧�<q����ҧ�x��C%�5u��9X����[w� g�-6/(��{ǟ؀wC�E�V�n�+��'))�*���0G���bJ�4��* I�oe#D�������ߙ=!Ρ��hju�?~��w����B�I��UZzߕ������Y�X�iI`Z�K�a���C��X
�����	��h� �R��!�2>ѣK*Rh�G��������D\�Dl��o�Ia`~ W�Qc%�J��7��40�:��z,0�F�?����������S�?�����#����/�P3��}]���9��w�������)��A@�_�?53%#�F�2Q3�r �+-3D��p������?K������'�������{��U�S�h�ZP��R��n��W����ϰ��O��u�����������ef���c2������t@ZF�˟������ѭ5���������u�g`����7��7�����j����H�U��n�����������.z�?�&z���0�����21�h�ot�_���s��?������7���z�7��ǳ��������
����_�)�����*�����i��@��������<���������dfdf2���r�������[��tLԌ?���@ �����`�*������������7������X_W�@G���7׉o��Lut,��t�5�M4T�Mt�hUL5���4��/g���z��b�Bt�T�O@�bt����00�4e��2��*���������
��%����*�~��U������W���I�j���F00�� 
E�+��L�UT@��\SG��HmA�DM
�G:�+:�+:̫��C����������ů��'�Cȫ��������?�:���t" ����~G�
E���S�^��=��T:�JT:*WWf��X���Lw�����k ���;4�!+T��O�0D!�d ���}L@]k}�k��G. ,���pt  �G����7<`��w�n�������op�?������p�?���������^y��7��?�!�N������!�C~�?� �8U��� U##}#��<��+k�+kh˫)j� ��L F�z&j e��S411h�+��܃��c�������@�D_���o�
�7P���W���-��4�u4�TA�˂�.O�}�������U6EUM���纀ꦊF* ~��<��4@��sq!yм\U]��D�H\�WG_OU\QI璷����U��߲�6�_&����ߥ���;��a�E]��e���߾��𗾂}���v�[:�_���	ĕ�����C?�HWx5ޏ���şp�+|�'�xU.����x�U~0��I�5��=��#\ç�����k���zp��C~�w�/�k8�u���_���5���~�.u
9��j�{ų	���A�7!�R��/i~�O  �=8���{�q�n���;���D�s�����/�3�ʯ�`p �����`�*�"�(��Z$ב;H�!ЍpU�0��r�Y�~;�:|S_�+ �  \%��� ~` �)��ou����OP�������u�WS����2l������ P���}����D7
?b0@��|�W�䛂 '�������x��8�p8@�8nP
y@!x�L�#pL�W	�d��� x'
��;Ȧ� %T?�wY���ø*�{�iP�3���l;����}���(H��  é+\�*� �_��U����ڞ3@�#P��  V @m
��� �S`dg�MW�P�8�?�Ʒ~�A΀or~t���t%gͷ)Y6����_�\�p$�'��|���)��v¥�"�\���q������9}���������˺��\W�_�r���u������$K5�_��YW����o������!���u������}
4NA:?��UW�.e��0��^��_��7�������Х�G�� �׭o����\W�!�2�*�~%o��u�_��O�U<�����~8��q)X�-�K��	J���ӕ��@r_���M.��ov`� �o���5%��-?ϫ�ۭ3��o�O,%d#y���d�S�@��������(C����d;i@<.W@e����d��2>���L5�
<Lxb�{z�嗣+ٹ�����e�L/��������:�v�-�k�c�����駗_@m����y�e���}�	J��F�u'�'�v�-� �`��!�`b�C����������u��T@5C�Yn��n���溹n�����_s��
q��jo��/k��q~%��q���Y���/
���z��g�2?���y����� ���~w�"��z����������=���o���_$���g�K�ػ訊s?s�&�$�,!�HPw	�H�$K��� ��]6$�����b���n�>��V�*%�P��i�����='9�E��"!hߢ@����;��Νl }<O{W��o����������M|~��}:�|�y�YK�+ǯ�M#į��}D�w����a=O�O��njTA��._�����)
����´����c�OGyH@�����2��Ll>��Ay(_w���s�{Ū��<Va��&��+�N��_�^� �&�v�4�o�o��3Cc�۳��,oX髯�����,(,�τ�:���ѳ�]��߸��h���u׬^�r
���_�[�)*/[H��*�f�V������.r/*�]9׭��7�Vk��� ���������h@�Ȏ��Q!�O4&��x���Q�¬���k
�Ґ�^�z�j��vR� �����L!c#R�U�Ux� ^����zVՀ1U��!�۳�
t�ԭr�n����%6��e�BTHhljP� �BQ��j�pdX'��U�!��7�Y��T��od�W�xm���j���C�ί^]W_�WW�E�ή��{n%j����%�5kV�>��Y���Mu
�.�B�?�E�G)Tu�����<����:�:�D[h,�_�(:�:�J\����2��B��ũ���I�+�l?3QK��sV:Iu�ڼ$�+�+y�+��Ezޥ�g�Dm~�w���C��ʕ_��]
ov���x��%n��ߝ>���'~���'f��{��g�{|�v�_&�}iG�yS��l�Sz�Ӫ���ް�I��)�e}zW����Oϙ��c�y�gc�n�|E�-���ۺ�wi�d͟�ճ6�v���q�sG�k�B�����h�@�H��z�@t�@O�%}�@�7|��	�Ž`}��.na�:����f�ՍF��ht�YR�ة�_�{�����@:X����G$-�����e� ?}�6��/�ч�X�>�Їɮ}���
�J�z).��,�Od
m��#a-�0��ڄ�������c��)�ړF^�O#���~�
5�b}�jmd�W���G�o�
�_\>��r�'��n͆����V^��
ʣ�[{� �"�dr}�`$2���2%����׃��?a�%����m(2Ps^�>�	g���ƻW�Na�����]B���O��%����s�{�=Uit�8����)l��k�lm����@��h���kJ\�f�(��0����_j� 3���ս\3��7kk?��E�}�D�p�D�5	���j>�auA<��a9����v\��Z��u��0�=M��:�*K��"/���+�e)�s:��B��3��$&*tM���4�fҋLY�b:NO'�P�Eھ�I�1�EiV��4�11J�Mv|/�f;Y&�f;	�Ei���Ҋ���ivx��l��'�tJԾ�f�Gp���l�������(�Vw�4;�2k�Ҥ��3��Xû6駄f�f��2J�_�Y�/2�]�k��WPÙ�Q�>�/��$W_ė�s����_Hϊ����^>�%��C�N���4}�r�.��`�tq������o�38��q���;��zy^����'8Z��J���(�㖞>��h]~*���v�~�8w���ƒi4F#Nۥ�����4F���Q�tRMc4�^�\{�ѭ��� es@�+���aH�u�,-�cO4ڣ>�hO���+�H����-��U��T��e���KF��1z+�>6$�?M6�;���đ�)1�p��x0�>�t�M�)�F���Nާ�����15����'�7��W󿏣U{r4�J��2a����b���J��9ęD�.�=�kM�b��G�ti4�z#'�Ԡ�B�*�x������_�@?$ЏK������!}W_���k�:���Qɸ�
c��{����wW��&6�ʄ�g��L�}.��AH�{�=ޔb�;�7�������m0��3K+�&.�����ZSl�N�R����ڀv��O�M+�`�q�9x��\(;-�[�<��ی��H��7ޞ�VDL���0�݀���˃`E��]Dbڇ�<�:6*�>>vD`���#*�n��e5bj�q�����vMk�C[��]������gi��W� \�5�5�h=��t�5�`���s�fUա%�W��_��ǰ�3��}u3�cU�Y�_�C�
8>\s�\nb>{�k�)�m��O&F�)�Ѳ����*��*�%ŵ[�����z�Q\�=����1��xl(���4>>_:J��5 ޹Q�z �^㛭�
2��EI��"e����~�Qu�O��������>>ص�\^2�XK*}7C]OU�\�~��|&p.��H���m� q�K
BxKdހ�i�7����nY� 1��V�2���B� ��:�1��N�����]K/u>6;�k��]t�8��W�{o��J�ݙ��;2\�s��;.cJ�0Q�&;_\:�TQy��Z�(��i?ޝzu�Z׿w��O
R�x-d��K���4��	���H.9�P:մ�>}rO���됎�*��}��K�������G֥����@i7/���Z=��D�i�l�7p8����}��fv��^���ܕ�����%]Ҿ����p�Ү����<A��晼c��{=A���m�����xׇ=|�$ϣ��ʮ�
F�"tRj7Hi�r��U���:���`�w�5���w���f�|����=N���9h��N�'u�
���F�uɕ��oUvUR��ި,��bt꼮ueA�����E�{�+�ϱ�:��6�v���W²�i�2%;�v�C�g���y�Q�
f��>����n�?��o{��wo�
~C�e�#�(��%ô��
v�Hv�@4�m�/�˂�W����
u�8i�4G
�m�fK����̼.S9�><��x�~�8?�[O�E�7������vu��,Ϧ8��/S2�B�KsBؤF��A� i�F3�ձ���	�3��EE�(�`�-t��=,�ˬ̔����8~Kb��	}Ch>8@�:�=��4�g�F��t�(NdD�.���Gԏʎ1����#��5��^7�������Pk�e3�S׏���.�^͕��.��s&��K77�(���	�힉st���=������O�HY���&s�e3���ʚMM���8^vl��vJ
��>״G�� �V��Hr_ZB$~4�d�t�Ȩ�a|��=aN�S���R�sM�Fo��S@A�F���_�<�s7M�+/(KdP�|��.j;����P�|y
�	�����W�G�nX	�/��t��ͤC׏�(V�eI�p:*���s&���ym�[Y��-��5e3�Yr6��Lm��n��V�@@5�e3u0�� ��_ŗ}�c�O����ڧ��a����;	2�&�Fu�(����zO��x�r���	e�U$7�"b��9akO9P����R�1�}�Cc���3��UO��L��74�_g�\�:X�v�����b-���LՓ.YIZt�5���uA~,�׵��y�3�y���5��k������B^���^�y	�X!����1��ׅ4*r��6��� �O/;���<G�vq1^c!��ZU�pZ��ңp��/��=��xd����e �'�$gD9!k7�w��4���$��?��f�CؽU~9!U;��g}sE�[k�[�;�GK��@���1T��0�D$]�n
�`:߭[,���2a�I�~3��S���IYC��$���Ve�4��Ȅe-���=:�䚎��K�㖭J¥��^�r��Cks�	4�� �9�m�eH�D��Y��`'J
���Qx[�h��A�EF��)=�^5�s���s#)�S%߮�q�v��<�c8C\ ��R��[<���Ê����2֟T���U�틪���C���@mM�gIF]rF����l����
fD�#R���Z)�+K��EΘ
,�J��-DpGi4�O�k�%�2�k
8����v4G�P�PVF�\�ꦆ��Ls���A65��15�!Ro��e�HMp����r�؜�`�?f���`��>c��!�7��ϟ�g�O>Ob�wГc��sF�
�=�@ڗl���K���w���T�@��iX�$�w�Ov {��.���ğ�̀�<s ��C�{	�W�.�=u����W�/1o�����*}d��Ý�
{��8�U�b��m��~K�d��1��gU�nk�L��1&�Ą�cr�����N��N]]�c�zF(kx�Obd�br�~�I�mkxL?�d�����b����w$�A'%���X�� �֐͈��zf�e��"���2g�4O���	e刳�b^���Ԋ�� �����b;�msa��	��{j��N��V�Y�d6�e��5,����ҡȅ0J^��M��'�w�4��~��F��"����7ȞQ�U�O��'�:B�{BɔK�P#^�źS	���,y^�Lg�����s���	HF�G[_
4�PU��Pyީ��G���p���F��[C�.>����!�)�=W{ɞ���P�����7}�6�(-�F���P���N��#{�. �,���#��=�(�����p7�8���	���$1�l_����(&�5��)R�Z�
hEd�R�(]�{ �ŅS?\Kr$���4׬ݢ�څ�`	m��]E0g��Y_� �/`����^�t�U=q�{����k�)b����c&b���3��1��8�/;E���~|�9)������N�/Ԋl2rs��~���h�5*2��osR��Mr]w#b��nn
��Af*ֻ];Ҭ���:����>�%,Ri�e:����,�L_K��}P�c8����KPΣx�|_�����l��<��k�^�7�!U�e^9/V�W��)rԏׯ�7hV����>i]	��kR�X��!�@?~�p���p���f�H�Lf#���nq��cu1TN�Ǭ�N��B�%ޮ&#�Mi��5�U%YD�S�׊8R�Q/jE�O͑���5Wܞ�f�oj�6�y ~rG�N��V��ߜ���sN떁Âp��7�]����h5Y�8��:�,�W�B�-�Ih��T7akw�i�^�E�APmr�;[uW����v�e��,���#�w��L �s0��ľjn�nr���_��S���3-C��("K߱��kO�K�3�����:G+�*n"�FG�$�x�}�Nj3Ŋ�s���3#5,̈́G�=^w���u�|mEc�èŽ���9���Kŧ_��SA1�g�ɟ6�$��F�,\BIF�&!
+u���5N�_{6Bz�OM���P�)���\ʚť(��^�.����q�7>���Q�F���߀FǒgGX�����2Q�a}B~RaS���"~��@�;F`:����5UU�,K�t���>I	�;}��>{}��}�� -��ɦ����}i3��p��T����Z��%��F��.�ca^_���ͪ�>�d����q�+'%�R�H
�Ƨ:a��[��]|R�u��&�l-�P�i�ΗX��n�g��͡�=5lpa�6%��Wc0�c��F�F�{�7�ںi���jG
���&i�Z~�Q%b����n��9�!��#��tO~Q>~���S�?g��G	�~ﻟC�6�6����H&���Ã�|녁ՙ
�|�{�5_`�������.,8�l���׎��!��#zߓ����	K6M�
��I~�<��w`��y�1"'�U�(�'����5z�9y�^�@�6��k��E�RC�ƒ#�
g=�0b:������h�~�o%���V<�:�*���V1-~��UA��t�P
�S,�/�4p
�'��|"~����y�(��!��bd�%PkY��C,Jw�:����0�f�`OK,r���!��g�e`�P��9\}q�>y�y�B~���7
�؎u�w��������so|�_h�c6f�xU쪣�Pd^�+�Z��8�iS�|��u�6���:�����}1�3��6�q�	Y�,}���a�M>aD��~��0s�M���5�/��Y�˒�~��z-��0u���
f[�F2I�"�;E�鋌&��%9%Y6
?�m<�}�=�).��S����4'�ӈsĹ���AIa�� ��mw�,�nz�=�k�FW[b])k���F��ڵ��#�?lt�ʚ��l�E�
4!b	�3��G�t�9�p?J`dtQ�:��s4KY1���[<V7�Ӊ�v����3u��$�Ӈ��!�i���+��L��b��H��N�"E� tH������@gNƚ�N:���jb3��+���a��2��t��`7�;Oa�!�k�� �ktp�c[��ccTg�b������=fOd�S��a�73g�B��4����&8�Ej\e�y\�;�l�9� ���?�z�gd��{ �n�ZCƌ`�mEO���Q~t�D�ٞ�z{�@�6��g��N��j���H㴫A�G	���Rl�U���|J���c���û1��x�"�	e�e��
��D|z��!��R��0��7O��R��zօCx�8��򦳝l|�OZ�Mh��uih�XhAw�ٓ�vz��H�
���b�F�^�/C(�_>A�Z�|�$�E�����p��S������G�)���^�zڟ�/I��)��?{^J����Y��n�}��H�oڧ��I���?��6��Tߴ_�c�P[�TЂ�[�D?<�}C-�Tߴ�tb.��b^j�F���⎛N��5�"w����Z`������z����%O�z	�[�ֶ5��t0�3��~��@���;���Zv�̤��l��9�݅�g�C���
�2��b�����1����L��ʑF��W���\��?V���w��U	���O��|%��2��x?��-^�����Ee�z�eQ1�dӢ��U^��!�lߒ�Mi���-�����h��V��x��%B.5��,~E[��̽�����(Ѐ�oɲe9�,��H��e�geF2�w0S�-ǻ[Q+�z�<��fZ0���Y%9��?��&�˴L��������!(�b�b�V�{^D�^�]څ�o"��9�]msb���hl��db������t�L��hla`���9��p�oS��@ZT����b��Ypo�{)����(��h�w��E%�"�m�	���8���A0#1!���h�m����t"L��B�E�ٿH�.���ʐ��t�	��М@�*�.�up���8-�HOc�>�
��������n<SNBX!&O#n_/a�yk_X��6���
�x�ɋ��J�������H~/�w$���z�
?�(��HI�:Rb�[���.C�x�l��~�����BF&��\�D�.J�����н9xO}#:#ʂQfd����o�{w���]Й��Z�?����3^��E�|���1z�k猢���b謰�4h�`�Iy3c��f��eݍxUUV�2u1��:��	��m�ז6���)����?�P��2"��ɦN��f�������Y��:�5g�m{�6pZjhˣ����2�0Wս0�UF���3֬�lhc�ǵ��78䦈"<�fT�7�ɼj���OM���(�Q�rz�\������N�Ҥثi"M��yI�(5�Dh��X�.;"a����i?�w�%i�O[�A������悍�(�3O�:h�Y]�w,)�lZ���,�����snLwM_K�cu�k4`A	M��+ z��T9�s$\��ս�9N��O\�~&�ޓ��
~���S��i��"���
A��xi�������]}��ݺ�M�:�
��R�}3$c�64[~�Ѻ�t��H�T�)��0s��1�?W��#a� �~���j��I�ʼf�r^�%��UN�N��C�=S*��2��/^q2{� \����f�#���檲~;A*oW9�%*�qx�C�#�lV�1p��<��x3b&��ѣĴ��KMv�I���ס��ß�yΕ>��-����Vl�n�`��(�K<1Ü���/~[��#�Q�����M�6B64]���!T[6����8*���k���q�Jr��lo	�^�בN����%j�lΤ��z�D�٧��J�'���-��9DX(H��٧�"
~������+SK-D��Z�>j�z¥j�D�
�d7aa���fb\ޡ�S��{�,9�E�|���tm�)���5�V,�!��V��?qI��A���p8�睺�#�׭'N^��#����[}͜z�nlC�c];��f��2��}�n��r�}Ļ��:� ��8��MG�YAl_��ܾ5����~h�?���>1�Y�������=!��irϧR�i�ڹ��Lr�3���D���<X�ˈ��ƽ��vb�����C��j�e��_l�{�\���"��o���F��5|��*�8O����ڐ�:vv�_L��w�Sw���Cc	���ʦ|��i'��=Z��oQ��TSq���q0��=�t!��"�n�a�qV����.m7�,*>!�%j��N�i|�Mj1��3 �$�_���:(���km�_IE_������B���؂�u\lu���͵ϲy�5=�����˄"���'B��-(f<��Rd�a��?-���3O�-�d��S{�"	��ڋg{Ye�J$;�����Ib�O��.�\ �W����?�&���1b�޸Q����kc�{?W+X��_���ƃ#��Tc�`�f�i�5�M�M��6�f�C��Ԃe��{R2�t}�n��v�6��u���H6�o�����k&4�3�[d��~|��k�ǉ��v����gaTx$Y|1甌l�<�fB��MiLhl����F/� �dSp>�Zӎ�k'�֙�򰩯�򴃢Ɇe+Fr:q(�����3���ZP��X"�5��T-#����R8���a1��fb7�e2�<E�<��u�2�.�R��\i%N�ֱ��r�Eq����
)v��P����=��3C�u���S�n�ot�<����lJ���eF��Ѱ���s���#��lE�͔ŭ�:��w��G8�sx?�b�����Z���S]e���v�w�+�oS�{�U��+�'���$���Ԣa��
���D=�w�k������k�V���v������'B�ﱌg'J����۽����N�7��y<b����6���ڱ�])��=��$qH�����%&���7���b/��,�k�nB�V���m��zd�}Ǧ��r��x���Ci��Ոҵ�yi"��fg��G�Z�A��k�߁�:H����%�;�� �寮����\��h�J��B���A��UӁ�С��ĸ�V�1_��u	������]���L#�y8����D���t�S8g����������#Α�޽�n�US`�
�]�蠠TٔB,	�">6���;���L����.�/�LL�m��؊[4�}������E�A�
�m�|��h��TY�1�جCYi��i 5�c�M�i��u�/�d��\_ZZWG�c�~0O����Ȝ"Y�:��J��a�	�g
���Cax�2R(�%���1�z�x�٪�c�{G��w"�#Y6�Տ[���[�W��+��(�Ⰻ���7jACZ()k�c W�e ��A�vI�;�ۖ��:�zG�K;�+[�D�Ov�'�U)�M��ڂ��ux#���.#���>T�vYJB;|�i
��*E'�v��^��tJ$��O��:ܗ��1���圼�?ſe���m}ﺥt���r����c��@��u�JG�չD�a�W�JqZ��eý����2�&��
�z�뻒����]oඋ���fʌ�[�c��: �>~B��]#ހ�x}W��~Vh�i��8BI
�,��K�a.Y#�k�%!��H�TbjJ�SI^��9�ʆ|0da�h�:}l�ѥߕ���@ܴx��&5c�8�\�i��a&��ZA/c��r0�B4��Pdf+�O����w9��0��t�zP���L�
�S6���
#�&1�V��zDW�o>	�JD?�&2>ֽO�=l#��kK�޳��{���7��O�dj�!��>�
y����a���'��xVN3����B���z��l�Y�
y[%mMG�D��h���4+f{͢��}8Vv[,�U07	mA2�R��'F���:���&�o�w��.��K<*n�	s��N*��W�g�0��4_�]?��0�=��v~A�g��w����;��(JcXȾ��-�̨e�4".�G��O|�灨"^џ=��I2�`K;�����D>誱:�cW�Җ
�&��]������}A/6+-(f���^ھ�߉?/�'����4|6v}δb�&��@ܯ��Y|�Jv�O4�VX���;,�*K���\7��S�>�Q�M:���El-�	3��o���O?2�u�z7���3�^b��(��z�M��n���̷�w����E���_}�爮�����^e�;d>�fp�\9�1w������������;���2p"ӫs�T��_��q3��YՆ9�w_?��1. �>�=��0C�e�9�ʁ�u1��e�d�N}�)�|bеm��r�f�����PI�N���Պ�E
��"�k��ќ�B����7����9��{GTo�����#����H;���".�ڏ��E$��~�)�Zl���L8&��R��>n��ǯ���dI>�� ]����2��sąu��^��R�Ot"r��D����3��!㩝p��o��lo����v���WlJ�Cp����~!�'�#��2��Ftշzt�{�/�U_��o���sI�.�ǝ$E����R~�&
��eh+�3°8~̸����|E�"�/��,�Wπ�8��l>�g߳�i~f*#A:W������(f�ـt�5e[L�A�N��~�8Z��f�����6=y��ݭ��ϲ��o�A��ƥ�W��CP�����M���9�d�=v3��"���r!�(�M��k��Y��*,>ִ4Ԍ��^�\2d��tN8�K�,�zʸ��f�e�m1_��S砗���gt�o�Ǻ8�o=m�;c�9rz���e~��t �Q���ϸ���(rF׻�S�/��]���%��/�w���Ag@� ���y�/ìl�?.hi��A�x�vA���@�1d:���V�����e�@�]�J�c|Z�%�M�8xy~̸3
�UP�<��׼����uE��x�M��g�q��֯��D�atQ|~�C�3���~
l ��S������v�����6u2���K��T��Vє���)'���������U�05����cQ���_6QeY6Ŧ�0��X�Wj7S��g�[C��#ϾdSIg�)�J"锎
fF��e<mT%6�f�#"&Q�T���ٱ��M���hq��8,i�D���D���6� ����33�FV\G~�q�4i�D������顨=���E1=�1��c�x/�[\�#a��;D1�YF��u���9V��YC�B>+y�����]�]�9F�!n�����3��ޯ��@n��4�x�)j��8nr��������n�U�t<���PƂ�=�	���"�:����"mW�?���Jh�����>�,\<zD�C�m3����� vd��~ܩ�Xwp�X	uZS�b�ڔz�%F�3f'�@�_~?*l�q;bw���c9�k��9L�{��$,1�v�� �HD1�"�㍱�q{��h�4��[m���]��$��;��]���t>���Na
f�v<���!�!���.��X��l�����>����a�8u�z��u�P�����T���?O\�_���~���B��o�1�$*��?'��Cd�>&C4u��B��|�����\N��|��%�6�|�w�ۄ�B9��� ��6��V#4_B�)��!�S��\�4��7��U��{�MF��<�ME`
+,>�T;
�>;1%P��3͵�ح��*���ӵ��>�W�itò����w��%�_!qj���*������*�-ڇ���/۴�<fw+
#��0��V,-
f����g�:�}D���	��^�}C�ڙ���ո�J������H����(�U#x�l��1B�/7j5���ӎ:�ӎm&�IR��-P:�؃���p�X��s��q���A
i���7"������!�����b�;�$6�Uc�c���S��ez.�i���_֜������w9�yGq?�އW���8��g����i�&{މ�?tN�o�~Թ�V
؇s�w9�~���W�{g}>zS1�x��:M���<�,i-\F`;9��Ȧ%F��>mک�D袳#l
�>��
���O�Q{ELvzΧ��>EZ�2s��_�ҹ��}�Xh�����3%�K�g�&�̉��YV��02F1�,�=N�4����]tᗎiu^���i'M�����ڟL19T�'p���{�E�]5m��H� 3���}�~O���ob(�˛�wXFz�_8�{�6-�b#|0��H�U؎ԁ����R�����j�
�M��uHl#���H�����҂�?yrƛ'�[#�|2�g��s�
.��������7T�BQ�^���A��:��/^
2d��$�e�)��_��NE��*�郅Խ�
�pM���w5^|�&��� _G$�ɀ��͈��'eR�4���Z��C���W2�q��0���n���r�"{5��g��#� l�_�o�V���[��ķ�@��B�F�Z�H.s�Mڇ�gt���ج��]}�֭޿y���':.Iw���tIM&�N��k��X���$�/kx-D�k��W���K+�N�K��_.)��5x��b���\p�����@×p��˷�>S��F\�%��K(N����*��㾯����gd�!�ρ"�2B�5ޚ}@�9 �{���!RҘL�ݴ�f��V�U璔W���c)�˦UH���x;�� ����'YO2A�GnGܺ[�������V�۱���Pr���;��k~1�E�k�kp�����C��[5Y|[�����W3��y���;!������2/[�x�g��/8vZ�6xC��Z�2��]�S��F��*�j��
R� �͆z?��W�\�X���z�~�a���[Z��Wf�ʖv�:0E/��5:�;0P�'����g��N��%&$r����f~�L ��t����:���H]
,F\`o��F3/�w;����k�]S_��֚�U�
�R�2R@�/����������z�}��n�Y�qŬj�T��9 �^��n�.{f/��J��v�Ӟ��l?�|�);���
�-�ۀ�dح�Ӑ�^D;���Z�-�+��vD�*�U6���p��f>
Qt���TmRvV+�m�Z�Q�~��y��<��ݙa7�b�3�h�g�
¥ݲ'���![���d�!��.C�~������͊��rN����y�!R);�S{Y"�E�w�/ �e0%��E�zY����G���Jg10�r���3|.�~9�Ǿ���^�193;�]f|^��C�{�Tp��	b��@��V"l�5 ��i[���v�IEDl�e��Ldz�q�u~4u&�k�y����z�k
`�և��s�O #�9��?W�Tl�����y���P�!-������Cz�q�5���U�^�̴b<�0&�
����e���"|6_ϕB������nэ�1��v$.��Z�����5��xI6;ϡF2c�C��/��o8R�T3�-@���Y"��i���!��ɍ=M�N�t��J��>�_�O��|N������e�O�Ĥy�'�2a�g���L�H v8���`
[�RٹY��E�)��$^|�K��D=w�Y�M���&ڛ�W���5���3���;U)W�z�^� �ـ:�t�7f�� f�>�C���ߝ��6 �iK;�������ρY~�����EJy��uo��`����)���y�:������Iޣ�n�+:C��:�s.���!:`ɐ�D�W�\�%~MP\X��l�BE����B��6��̸|�J�GQX/��ɛ�5��
m?V�ⴼm%���#ٗ��wR��T��v��zc9�SR�iV%`i6J�3�ͪS���XI�Hc��,V	��+�?G����o�0��fI��}�����U�I��3G)�y�O�unG�Wq^ǲ`E'%���m�d�އ����,Vta1گ�'w����>~�� �_�ogE0DҼ�11�fQ�єb�-�
��yQ�5ʰ��m4X��p��l�t�
�7V�z��A�"���$�����m8�� �z���"��ꔎRMT2�����%E�*9ݡ\2��tpП�-yS����P��Q���(��4g��1L!�ϥ�6h�Gg�D�p�����C�E���<9���|i�����MV�����G�a�kLV2�ԁ]����1���Of�@I����!~�&��Q�y3G2r�<����o߬
:�Y��@��LzV�ʍ�z�}�ۑZŜ��~��v�S��$
��\�^��7����o2�;�ְ���Z�q_;���q�џ��UM������
��gb�5N7�`�{p+����f�����_B�+���ݹ�j� 󙱈�f�����s��Qa�4�ce	8�<#^Y}��9�V}��x���~����d;����Ѐ�>ŰM���L�.�@�� wjƗ�_�����k��hko�m�u�%��~�9D�ĦR�r�	2fL���y��� o|�7*L��m�&̛zS��7�|���d�yC��c_c>{?s�� �È۠Ҋ9I�t�3X��w�ߴ�3jv5l\؋�/B�0���
�e��.b����%Y��U�(���e������6���n%����jF:^��	��� ��C�N*��_)�#�[�}d��|�]�4d��O�$tJ���Ѝ Y@��7�|�(�/���T�7����-��t^
�0����H] � �-=pJp�0�1](�3�-C�1?�K���ޢ�Z�������-�7��W
c�1��b����V�!�� �)��ԋ6�����]\�/%�����������u��{��^g$�����<�.Tpႋ\��	� �\����
�Dp��{Lp���v
n��^�a��%������W�;/����Ap]���H�rJ�.Tpႋ\��	� �\����
�Dp��{Lp���v
n��^�a��%������W�;/����Ap]���h��) �P��.Vpɂ�&8��r7_pKW(��U
�1�m�S��)�}�{Ip������G��Bp_	��.
��u	�Wp"o�S
.@p��\���7Mp��
n����Pp%���c��(���Sp�����-��'������y�]���\����	�K`,��s���!�4��WV^TQQT�� ����0�'BzIi��5��+�d!Cѯ���D���mJR�(�\]F��*B���~D�@�D��jt&BO�t
Я�2�
�D�(M@K�TtjBG�h#�b�[�O����}�>D��G�c�	�#:�>E���!��)�t����_�ߎn���Ր�e^�$I����L�
���a58�%r���Z71$�=$��d�� J6(L���<H`�lpX4$,v���J��a)98,�����C�{
i��S&NJ���O7d08� ,YAa�r~Ml�꒒(���#C��UˋWW��x��g�9y��}|i��[~qVX�|���q���]���7m�O�~�_�o��s�_��ا� �+�ʜ��w�_wi��E���~��_�O}�2�,��OKG�l�?�W����V~p(M�f����t�S�Uc�i��Ͽ��bp�a��Y�?s&Í�o�H�5�j8�6����3z���������Sy���hof��Y4��b���������qpsZ���H���'�ɯ�,�/,*�����:95y���
6����������H�:C}mBR"JH֦�$$&OJ���MJ�DDW�'���2������O��++�WMO������8qrJ|��ԄI��R�/�&M���4i�6~2x��&�$�؂��N���N���۷�w�����~��?)%e���<)ih��8Q;x��?���KK+
���V�ɥ	���xՄe 
�b
��,�y��+�"���W�E�+�Ek����ˋ�W��//݁��ӥkV���+fD�}lU��^��']�_QD��]E���Z�����(������N�J�OX�'�KW���BI*+צ���҉tBF38��.�Rw�W��C���2(���S��^œ/�*�� ���V��W���Uk���Eti9
��i�@JE#�w�$���!���|\���Ԇ��h�Ox����O�l��~��{���ۤ�}�t|~� ���g:̛�q������~&58)�c�t���>G���	.U�7�Z���
xC}�[D||ͻTY�_�o���1�/A�}w~�A:ɿ!���+�7\;�L��r6��x���	%�q%ūVW�U�N���_Q��_.� S3g/���&B�]�� !����z����D{��Uꅧ�Y���M�p���s#���'���_��y�?��)>�����F���0�a��a����g/��0�`��a�Y�����e��a�9e�pw|�� ��DT�O"�ҥ0B�XZ��X�<���kY�Qe����娸���2<����,ʯ,-A%�E���h�З.-��_
s����uE�Y�L`��2�xZS�l-�OQ���,}����������4k���0s(z�����|�������_V��?��t�@v����.)�����ǽ;D�n�_����9�:�X�1_@���[�	�`7	p�n0�>#츒x�|Y<�����x��p���;<��rR&��C�A���o��s|����=�upO���.����{�/{�=߳;�Wz��z�Gx��<���p�q��{׌�{ݽ�^w�����ߺ��������,s�����nj�$��>���)S |�1<�q<>�U����:��:>L�as����)>������b>��?,����a)~�?,����a9��?���i�a/>��V��0wj�c<����/�5$�1$<}H8eH8nH8bHx̐��!�C��!�[q���=�	?fm6�2s��37\����}Z�8�����7���y�t�A�f���bo��r$���q.ѐ;->�L���>���|������\��������$>�4�U �M�Ӳ�/�;=.�i�.<;_� s��e�6s�Je����!p�>��J!4�'�&�����"��H�U\̗gd
���g��j��d�������W�n�W~��m돽y�}w���x��a��GG!��N)}rW�^57!�|u�PD�P��!���
ţ�A������]����>����E���OO_<��_dm�Kڂ�����m�]��t\.���F��c�oNg����q	�}���j��6[Ӝ�dn8NdN������L[��`�/Ӗ_�<�g������@�o�?
��.�s!��ם�*�#o8����
���Ϥ��k��B{����L�M�_'����	~��[�S������83=}
�`��U�����I�ڸ�I��`¯����(�_�I��;���}��T����pz�pq�|�K��z0\�/���~�����`��_ný��{0\9x�g?|�����F
� ����5�}���`��7+Sȿ�`x J
#p�T�8z���@�y�������m�@�S��	�����K\� �B'㓷�Ǌa�<3��a�G��>�oB�B�����]����z
�tia�҇JJ��u�������PA�ʲ��ʢ��T�D흑�+(�K�����.-ZUY�-�b,���$���\�A���Z-@�QiI!>�x��RH��M���4c�a�R$�òt0�B�����YY�c�7V 4s�����L�\�tfn�>-wi��˘�t~�>7c�������|}~��uף�K6:ݠ�i�
�+�o{�g )��v��t����w�����\onhH���r	�q=�������K��U�%����Z.�����UKWWz2s��**���G�o)
=����r:�$�|=m͚50�@ǯ*��WAG���'ϖAdy�J|����"��ty%���T�{���������e�+��k�WN(-�W�/_�� l��B|.[D�U�
�t9�9{=�hUQy~	=g����:�� �/���5�T�E��2�N��2��@3�@8�3�JC|9-,�Љ�<��ti9&���
~rw-]�_9�4�\�����ʵxcrEѪB��k�sE�#��V�cs�Ο�+M����6��'_����3K�������WW���@�p�t���\�_
�)��O�RA���R�B��tfQ�Rzviiy!�� ��7�����5Q@`��;H�6i(�i,�צA��J�X~W \��*(Y
�S���Y)���GC��t�R�@�X:o�\��s���A�q	Q�+W����Si`Y^$��.2���H�JFy�пJ��qP�~���xe9.�'W�#��,/��~l:�-���1:=7/=-w0Z)�6��,�xD`}V��`^�R&W�;���\T 4O8u��xUrz>�O�_EcтV�jݝ)���@��JWŭ+*/Ū�buAAQE���%��)4�h��A�B��
R�;q��7�,:t�K�O��_|���u�[�|q�}n���1�bdf��ti;,�?�����A�WWx���\�^%V������BNӮ8����PRC���@���?>���B�X���K����ϚwG��N�zh�
:��-輟)� MP?����:䅮�*S��O2u ����A����,��J��xd�1�7�ր���V�£��ɋ{@V%���S�Jޜ��_^\
u*卆�⢂��j��'�K���e
B��r�>��o۹�@���G�*hW�A#q��?TK�F�����Ɨ+䘁8vZ���$��&E)��0��Yp������%����l���	w�N���c��˖�`�P�	@B�V�?�G�~#xy����%��\|Ūʅ�,LZ�_�S%�-�a4��z;��Pr���kd
���@CR����������U��dW!!��\��t�����xι)��.�&>� ����?�y�AM���F�7�������J�������=1����.��
0��2w)�=�����O-�_�v���3���ص���s�Z?W��ӱk���<v
A�����)�)�Bw~_g<�_^�
D���W,�_�}�D����z^	��{���ۆ��Zޓѝ�������������{�W�����E��_e�;�wh��������L��a��}����	n����
�_}�@+��G?ÿ��78*���g�߽�^w������u��{ݽ�^w������u��{ݽ�^w������u�������� � 