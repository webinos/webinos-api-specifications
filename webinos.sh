#!/bin/bash

if [ $# -eq 2 ] # good arguments 
then
   echo "Using " $1 " as repository for API stuff " $2 " as the spec destination"
   SPECHOME=$2
   REPOS=$1
else
   echo "This script requires 2 arguments: The location of the repository and the destination directory for the spec (both full paths). The first argument should point to a folder with three folders: static (where static html files are stored), widl (where WebIDL sources are stored) and resources (where additional resources such as wildproc, dtd, xsl... are stored). If the operation completes successfully the spec will be generated in the apis folder created on the specified destination folder."
   exit
fi

# API Files that do not come from widls (edited manually) 
#STATICFILES='geolocation.html webinos-apis.js webinos-apis.css'
STATICFILES=$(ls "$REPOS/static/")

# Device API widls
#WIDLFILES='foo.widl'
WIDLFILES=$(ls -I "*~" $REPOS/widl/) 

# For widlproc processing
XSL=widlprocxmltohtml.xsl
XMLSOURCES=widlprocxmlsources.xml
DTD=widlprocxml.dtd

# get the right tools for unix of windows cygnus
$(widlproc 2> /dev/null)
[ $? != 127 ] && WIDLPROC=widlproc || WIDLPROC=$REPOS/resources/linux/widlproc 
[ -n "$OS" ] && [ "$OS" = "Windows_NT" ] && WIDLPROC=$REPOS/resources/win32/widlproc.exe
[ "$(uname)" = "Darwin" ] && WIDLPROC=$REPOS/resources/macos/widlproc

$(ls /opt/bitnami/common/lib/libxslt.so > /dev/null 2>&1)
[ $? = 0 ] && XSLTLIB=/opt/bitnami/common/lib
XSLPROC=xsltproc 
[ -n "$OS" ] && [ "$OS" = "Windows_NT" ] && XSLPROC=$REPOS/resources/win32/xsltproc.exe



#[ $? != 127 ] && WIDLPROC=widlproc.exe || WIDLPROC=$REPOS/resources/win32/widlproc.exe

# TODO: Here we should include an update to check the latest repository version is available
# Clean Directories used for the generation of the specs
rm -rf "$SPECHOME/apis"
mkdir "$SPECHOME/apis"

# Copy static content
for i in $STATICFILES
do
  cp "$REPOS/static/$i" "$SPECHOME/apis/"
done

# Generating dynamic content

# those files are required to be in the destination folder for HTML generation
cp "$REPOS/resources/$DTD" "$SPECHOME/apis/"
cp "$REPOS/resources/$XSL" "$SPECHOME/apis/"

# is done in three steps in order to build the cross-references
for i in $WIDLFILES
do
        "$WIDLPROC" "$REPOS/widl/$i" > "$SPECHOME/apis/$(basename "$i" .widl).widlprocxml"
        if [ $? != 0 ]
        then
                echo Error: could not process $i
                WIDLFILES=${WIDLFILES//$i} # remove widl with error from further process
                rm "$SPECHOME/apis/$(basename "$i" .widl).widlprocxml" 
        fi
done

cat > "$SPECHOME/apis/$XMLSOURCES" <<DELIM
<?xml version="1.0" encoding="utf-8"?>
<widlprocxml>
DELIM

for i in $WIDLFILES
do
        cp "$REPOS/widl/$i" "$SPECHOME/apis/"
        echo "<file>$(basename "$i" .widl).widlprocxml</file>" >> "$SPECHOME/apis/$XMLSOURCES"
done
echo "</widlprocxml>" >> "$SPECHOME/apis/$XMLSOURCES"

unset GIT_DIR
for i in $WIDLFILES
do
        DATE=$(cd "$REPOS/widl" ; git log --pretty=format:'%aD' -1 "$i"|cut -d " " -f 2-4)
        LD_LIBRARY_PATH="${XSLTLIB}" "$XSLPROC" --stringparam date "$DATE" "$SPECHOME/apis/$XSL" "$SPECHOME/apis/${i}procxml" > "$SPECHOME/apis/$(basename "$i" .widl).html"
done

cat > "$SPECHOME/apis/index.html" <<DELIM
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link media="screen" href="webinos-apis.css" type="text/css" rel="stylesheet">
<title>webinos Device APIs - working repository</title>
</head>
<body id="content">
<div class="api">
     <a href="http://webinos.org"><img src="http://webinos.org/wp-content/uploads/2011/press_releases/webinos_thumb_150x48.png" alt="Webinos Logo"></a>

     <h1 class="head">webinos Device APIs - working repository</h1>
</div>
<p>This page lists all API specifications that are defined or referenced/used within the Webinos project.</p>
<p>The APIs listed here are to be considered 'work in progress'. The official stable webinos API specifications are located at 
<a href='http://dev.webinos.org/deliverables/wp3/Deliverable34'>http://dev.webinos.org/deliverables/wp3/Deliverable34/</a></p>
<p>Webinos is exposed under the <code>window.webinos</code> object. The <a href="http://dev.webinos.org/specifications/api/webinoscore.html">Webinos Core Interface</a>, the 
<a href="http://dev.webinos.org/specifications/api/servicediscovery.html">Webinos Discovery API</a> and a few more Webinos APIs are available directly 
under this name space.</p>
<p>However, one of the key elements of Webinos is that the framework provides means to <strong>bind to a service object in a remote execution 
environment</strong>. The <a href="http://dev.webinos.org/specifications/api/servicediscovery.html">Webinos Discovery API</a> defines how a service is 
discovered and how an application can bind to a remote service. The service object will act as proxy for sending/receiving events to/from the remote 
peer and hides the complexity of sending/receiving message between the peers in a trusted manner. This mechanism is not limited to Webinos defined 
APIs but is also available for the APIs defined by W3C referenced below and also to user defined APIs.</p>
<p>Most Webinos APIs defines services that are discoverable through the 
<a href="http://dev.webinos.org/specifications/api/servicediscovery.html">Webinos Discovery API</a> and are therefore not exposed directly under
the <code>window.webinos</code> object. Instead these APIs inherit the general <a href="http://dev.webinos.org/specifications/api/servicediscovery.html#::Service">Webinos Service Interface</a> that is defined in the 
<a href="http://dev.webinos.org/specifications/api/servicediscovery.html">Webinos Discovery API</a> </p>
<p>For more information see <a href='http://dev.webinos.org/specifications/api/servicediscovery.html'>Discovery API</a> and <a href='http://www.webinos.org/content/html/D033/index.html'>Architecture Specification</a>.</p>

<div class="api">
  <h2 class="head">APIs Specified by Webinos</h2>
</div>
<div id="content"><table><thead><tr><th>Specification</th><th>Summary</th></thead><tbody>
DELIM

for i in $WIDLFILES
do
    if [ "$i" != "foo.widl" ] && [ "$i" != "calendar.widl" ] && [ "$i" != "gallery.widl" ]  ; 
    then
        basename2=$(basename "$i" .widl)
        htmlfile="$SPECHOME/apis/"$basename2".html"
        LD_LIBRARY_PATH="${XSLTLIB}" "$XSLPROC" --novalid --stringparam basename "$basename2" --html  "$REPOS/resources/getAPIdata.xsl" "$htmlfile" >> "$SPECHOME/apis/index.html"
    fi
        #basename2="$(echo ${basename2:0:1} | tr 'a-z' 'A-Z' )""${basename2:1}"
        #echo '<li><a href="./'"$(basename "$i" .widl).html"'">'"$basename2"' API</a><br /></li>' >> "$SPECHOME/apis/index.html"
done
echo '</tbody></table></div>'  >> "$SPECHOME/apis/index.html"

echo '<div class=api> <h2 class=head>Referred APIs used by Webinos</h2> </div>' >> "$SPECHOME/apis/index.html"

echo '<div id="content"><table><thead><tr><th>Specification</th><th>Summary</th><th>Feature URI</th></thead><tbody>' >> "$SPECHOME/apis/index.html"

echo '<tr><td><a href=http://www.w3.org/TR/2011/WD-orientation-event-20111201/>The W3C DeviceOrientation Event specification</a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification defines several new DOM event types that provide information about the physical orientation and motion of a hosting device.<br/></p></td><td><code>http://webinos.org/api/w3c/deviceorientation</code></td></tr>' >> "$SPECHOME/apis/index.html"
echo '<tr><td><a href=http://www.w3.org/TR/2011/WD-FileAPI-20111020/>The W3C File API </a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification provides an API for representing file objects in web applications, as well as programmatically selecting them and accessing their data.<br/></p></td><td><code>http://webinos.org/api/w3c/file</code> (all file APIs)<br /><code>http://webinos.org/api/w3c/file/read</code> (file read only)</td></tr>' >> "$SPECHOME/apis/index.html"
echo '<tr><td><a href=http://www.w3.org/TR/2012/WD-file-writer-api-20120417/>The W3C File API: Writer </a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification defines an API for writing to files from web applications. This API is designed to be used in conjunction with, and depends on definitions in, other APIs and elements on the web platform such as the W3C File API.<br/></p></td><td><code>http://webinos.org/api/w3c/file</code> (all file APIs)<br /><code>http://webinos.org/api/w3c/file/write</code> (file write only)</td></tr>' >> "$SPECHOME/apis/index.html"
echo '<tr><td><a href=http://www.w3.org/TR/2012/WD-file-system-api-20120417/>The W3C File API: Directories and System</a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification defines an API to navigate file system hierarchies, and defines a means by which a user agent may expose sandboxed sections of a user local filesystem to web applications. It builds on the File Writer API, which in turn built on the File API, each adding a different kind of functionality.<br/></p></td><td><code>http://webinos.org/api/w3c/file</code> (all file APIs)</td></tr>' >> "$SPECHOME/apis/index.html"
echo '<tr><td><a href=http://www.w3.org/TR/2012/PR-geolocation-API-20120510/>The W3C Geolocation API</a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification defines an API that provides scripted access to geographical location information associated with the hosting device.<br/></p></td><td><code>http://webinos.org/api/w3c/geolocation</code></td></tr>' >> "$SPECHOME/apis/index.html"
echo '<tr><td><a href=http://www.w3.org/TR/2013/WD-mediacapture-streams-20130903/>The W3C Media Capture and Streams API</a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification defines an API that provides access to the audio, image and video capture capabilities of the device.' >> "$SPECHOME/apis/index.html"
echo '<br/></p></td><td><code>http://webinos.org/api/w3c/mediastream</code></td></tr>' >> "$SPECHOME/apis/index.html"
echo '<tr><td><a href=http://www.w3.org/TR/2013/WD-webrtc-20130910/>The W3C WebRTC API</a></td><td><p>' >> "$SPECHOME/apis/index.html"
echo 'This specification defines an API that allows to establish peer-to-peer connections between browsers, and transmit media streams and data over these connections.' >> "$SPECHOME/apis/index.html"
echo '<br/></p></td><td><code>http://webinos.org/api/w3c/webrtc</code></td></tr>' >> "$SPECHOME/apis/index.html"
echo '</tbody></table></div>' >> "$SPECHOME/apis/index.html"

echo '</body>' >> "$SPECHOME/apis/index.html"
echo '</html>' >> "$SPECHOME/apis/index.html"

rm "$SPECHOME"/apis/*.widlprocxml
rm "$SPECHOME"/apis/*.widl
rm "$SPECHOME/apis/$DTD"
rm "$SPECHOME/apis/$XSL"
rm "$SPECHOME/apis/$XMLSOURCES"

