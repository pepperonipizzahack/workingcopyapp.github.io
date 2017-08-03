#!/bin/bash
#
# Create static versions of ../manual.html where OpenGraph and Twitter meta tags use
# section specific summary and images

base=..
file=$base/manual.html

sections=`grep -E < $file 'id="' | awk -Fid= '{print $2}' | awk -F'"' '{print $2}'`

for section in $sections; do
    echo "$section:"
    markup=`grep -E -A80 < $file "id=\"$section\""`

	# only grab until next section
    markup=`echo "$markup" | sed -n -e "/<h[1-4][^>]* id=\"$section/,/<h[1-4] id=/p"`
	
	# filter out <pre> blocks taking care to remove single-line pre blocks first
	markup=`echo "$markup" | sed -e "s/<pre[ >].*<\/pre>//g"`
    markup=`echo "$markup" | sed -e "/<pre>/,/<\/pre>/d"`
	
	# echo "$markup"

	# when things are working we need to output this markup
	# echo "$markup"
	echo ------------------------------
	
	# extract title
	title=`echo "$markup" | grep -E '<h[1-4] ' | head -n 1 | sed -e 's/<[^>]*>//g' | sed -e 's/^ *//'`
	title=`echo "$title" | sed -e 's/^[ 0-9.]*//' | sed -e 's/&[^;]*;//g'` # remove section number and html entities
	echo title="$title"
	
	# extract summary
	summary=`echo "$markup" | sed -n "/<p>/,/<\/p>/p" | sed -e 's/<[^>]*>//g' | sed -e 's/^ *//' | tr '\n' ' ' | sed -e 's/ +/ /g' | cut -d ' ' -f 1-250 `
	summary=`echo "$summary" | sed -e 's/["\/]//g' ` # remove qoutes and slashes
	echo "$summary"
	
	# extract image
	imginfo=`echo "$markup" | grep -E -A1 '<img ' | head -n 2`
	image=`echo "$imginfo" | awk -F'srcset=' '{print $2}' | awk -F'"' '{print $2}'`
	# echo "imginfo=$imginfo"
	# echo "image=$image"
	if [ "$image" == "" ]; then
		image=`echo "$imginfo" | awk -F' src=' '{print $2}' | awk -F'"' '{print $2}' | tr '\n' ' ' | sed -e 's/^ *//'`
	else
		# grab last source
		srcset=`echo "$image" | tail -n 1`
		image=`echo "$srcset" | awk '{print $(NF-1)}'`
	fi
		
	# compose content
	#  <title>Working Copy Users’ guide</title>
	#  <meta name="twitter:title" content="Working Copy - Users Guide">
	#  <meta property="og:image" content="https://workingcopyapp.com/img/split-diff-36-1364.png">
	#  <meta name="twitter:image" content="https://WorkingCopyApp.com/img/action-shot-71.jpg">
	#  <meta property="og:description" content="Learn how to use this powerful Git client for iOS, for ...">
	#  <meta name="twitter:description" content="Learn how to use this powerful Git client for iOS, for ...">
	content=`cat $file | sed -e "s/<title>[^<]*<\/title>/<title>Working Copy - Users Guide - $title<\/title>/"` || exit
	content=`echo "$content" | sed -e "s/<meta name=\"twitter:title\" [^>]*>/<meta name=\"twitter:title\" content=\"Working Copy - Users Guide - $title\">/"` || exit
	
	# replace image when valid
	if [[ ! -z "$image" ]]; then

        image="${image#"${image%%[![:space:]]*}"}"    # remove leading whitespace characters
        image="${image%"${image##*[![:space:]]}"}"    # remove trailing whitespace characters

    	imgsrc="https://workingcopyapp.com/$image"
		echo "image='$imgsrc'"
				
		# we use ! as regular expression delimiter intead of /
		content=`echo "$content" | sed -e "s!<meta property=\"og:image\" [^>]*>!<meta property=\"og:image\" content=\"$imgsrc\">!"` || exit
		content=`echo "$content" | sed -e "s!<meta name=\"twitter:image\" [^>]*>!<meta name=\"twitter:image\" content=\"$imgsrc\">!"` || exit
	fi
	
	# replace description
	content=`echo "$content" | sed -e "s/<meta property=\"og:description\" [^>]*>/<meta property=\"og:description\" content=\"$summary\">/"` || exit
	content=`echo "$content" | sed -e "s/<meta name=\"twitter:description\" [^>]*>/<meta name=\"twitter:description\" content=\"$summary\">/"` || exit
		
	# write to file
	mkdir -p "$base/manual/$section"
	# echo "$content" > /tmp/test.html
	echo "$content" > "$base/manual/$section/index.html"
	
	echo
done
