#!/bin/bash
# usage: ./say.sh sample-text-file Thomas Tom 200
# usage: ./say.sh text-file name_of_fren_speaker name_of_english_speaker speach_rate
V1=$2
V2=$3
R=$4

cat $1 | sed '/^$/d' | tr "\n" "§" | sed -e 's/§\([^_]\)/\ \1/g' -e 's/__NS_/__LP_\"§((N=N+1))§S=0§M=0/g' -e 's/__NF_/__LP_\"§((S=S+1))§M=0/g' -e 's/__LP_/...\ .../g' -e 's/__P_/.../g' -e 's/__FR_/\"§((M=M+1))§say\ -v\ '$V1'\ -r\ '$R'\ -o\ output-$N-$S-$M\ --channels=2\ \"/g' -e 's/__EN_/\"§((M=M+1))§say\ -v\ '$V2'\ -r\ '$R'\ -o\ output-$N-$S-$M\ --channels=2\ \"/g'| sed s/$/\"/ | sed -e 's/^\"/N=0§S=0§M=0§/' | sed -e 's/M=0§\"/M=0/g' | tr "§" "\n" | bash -
J=`ls output-*.aiff | tr "\n" "§" | sed s/-[0-9]*.aiff//g | tr "§" "\n" | sort -u | wc -l`
((J=J-2))
for j in `seq 0 $J`; do
        K=`ls output-$j-*.aiff | cut -d '-' -f 3 | sort -rn | head -n 1`
        for i in `seq 1 $K`; do
                echo > input.txt
                L=`ls output-$j-$i*.aiff | cut -d '-' -f 4 | cut -d '.' -f1 | sort -rn | head -n 1`
                for k in `seq 1 $L`; do
                        echo "file 'output-$j-$i-$k.aiff'" >> input.txt
                done
                output=${j}.0.${i-1}.ogg
                if [ $K -eq 1 ]; then
                        output=${j}.0.ogg
                fi
                touch out.aiff
                ffmpeg -f concat -i input.txt -c copy  -loglevel quiet -y out.aiff
                ffmpeg -i out.aiff -strict -2 -acodec vorbis -f ogg -loglevel quiet -y -ab 192000 ${output}.ogg
                rm input.txt out.aiff
        done
done
rm *.aiff
