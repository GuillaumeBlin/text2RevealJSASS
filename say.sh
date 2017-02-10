#!/bin/bash
# usage: ./say.sh sample-text-file Thomas Tom 200 180 500 1000
# usage: ./say.sh text-file name_of_fren_speaker name_of_english_speaker french_speech_rate english_speech_rate short_pause_duration long_pause_duration
V1=$2
V2=$3
R1=$4
R2=$5
D1=$6
D2=$7

cat $1 | sed '/^$/d' | tr "\n" " " | sed  -e 's/^/N=0§S=0§M=0§/' -e 's/__LP_/\ [[slnc '$D2']] \ /g' -e 's/__P_/\ [[slnc '$D1']]\ \ /g' -e 's/\ _/§_/g' -e 's/__ES_/__NS_§__FR_\ ...§/g' -e 's/__EF_/__NF_§__FR_\ ...§/g' -e 's/__FR_\([^§]*\)/((M=M+1))§say\ -v\ '$V1'\ -r\ '$R1'\ -o\ output-$N-$S-$M\ --channels=2\ \"\1\"§/g' -e 's/__EN_\([^§]*\)/((M=M+1))§say\ -v\ '$V2'\ -r\ '$R2'\ -o\ output-$N-$S-$M\ --channels=2\ \"\1\"§/g' -e 's/__NS_/((N=N+1))§S=0§M=0§/g' -e 's/__NF_/((S=S+1))§M=0§/g' | tr "§" "\n" | bash -

J=`ls output-*.aiff | tr "\n" "§" | sed s/-[0-9]*-[0-9]*.aiff//g | tr "§" "\n" | cut -f2 -d"-" | sort -rn | head -n 1`
for j in `seq 0 $J`; do	
	((p=j+1))
		K=`ls output-$j-*.aiff | cut -d '-' -f 3 | sort -rn | head -n 1`
		for i in `seq 0 $K`; do
			echo > input.txt
			L=`ls output-$j-$i-*.aiff | cut -d '-' -f 4 | cut -d '.' -f1 | sort -rn | head -n 1`
			for k in `seq 1 $L`; do
				echo "file 'output-$j-$i-$k.aiff'" >> input.txt
			done
			((q=i-1))
			output=${p}.0.${q}.ogg
			if [ ${i} -eq 0 ]; then
				output=${p}.0.ogg
			fi
			touch out.aiff
       		ffmpeg -f concat -i input.txt -c copy  -loglevel quiet -y out.aiff
       		ffmpeg -i out.aiff -strict -2 -acodec vorbis -f ogg -loglevel quiet -y -ab 192000 ${output}
        	rm input.txt out.aiff
		done
done
rm *.aiff
