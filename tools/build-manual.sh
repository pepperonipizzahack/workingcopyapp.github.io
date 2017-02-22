#!/bin/bash
#
# Create static versions of ../manual.html where OpenGraph and Twitter meta tags use
# section specific summary and images

base=..
file=$base/manual.html

sections=`grep -E < $file 'id="' | awk -Fid= '{print $2}' | awk -F'"' '{print $2}'`

for section in $sections; do
    echo "$section:"
    markup=`grep -E -A40 < $file "id=\"$section\""`

	# when things are working we need to output this markup
	# echo "$markup"
	echo ------------------------------
	
	# extract title
	title=`echo "$markup" | grep -E '<h[1-4] ' | head -n 1 | sed -e 's/<[^>]*>//g' | sed -e 's/^ *//'`
	echo title="$title"
	
	# extract summary
	summary=`echo "$markup" | sed -n "/<p>/,/<\/p>/p" | sed -e 's/<[^>]*>//g' | sed -e 's/^ *//' | tr '\n' ' ' | sed -e 's/ +/ /g' | cut -d ' ' -f 1-80 `
	summary="$summary..."
	echo "$summary"
	
	# extract image
	imginfo=`echo "$markup" | grep -E -A1 '<img ' | head -n 2`
	image=`echo "$imginfo" | awk -F'srcset=' '{print $2}' | awk -F'"' '{print $2}'`
	if [ "$image" == "" ]; then
		image=`echo "$imginfo" | awk -F'src=' '{print $2}' | awk -F'"' '{print $2}'`
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
	content=`cat $file | sed -e "s/<title>[^<]*<\/title>/<title>Working Copy - Users Guide - $title<\/title>/"`
	content=`echo "$content" | sed -e "s/<meta name=\"twitter:title\" [^>]*>/<meta name=\"twitter:title\" content=\"Working Copy - Users Guide - $title\">/"`
	
	# replace image when valid
	if [[ ! -z "$image" ]]; then
		imgsrc="https://workingcopyapp.com/$image"
		echo "image=$imgsrc"
				
		# we use ! as regular expression delimiter intead of /
		content=`echo "$content" | sed -e "s!<meta property=\"og:image\" [^>]*>!<meta property=\"og:image\" content=\"$imgsrc\">!"`
		content=`echo "$content" | sed -e "s!<meta name=\"twitter:image\" [^>]*>!<meta name=\"twitter:image\" content=\"$imgsrc\">!"`
	fi
	
	# replace description
	content=`echo "$content" | sed -e "s/<meta property=\"og:description\" [^>]*>/<meta property=\"og:description\" content=\"$summary\">/"`
	content=`echo "$content" | sed -e "s/<meta name=\"twitter:description\" [^>]*>/<meta name=\"twitter:description\" content=\"$summary\">/"`
		
	# write to file
	mkdir -p "$base/manual/$section"
	# echo "$content" > /tmp/test.html
	echo "$content" > "$base/manual/$section/index.html"
	
	echo
done
