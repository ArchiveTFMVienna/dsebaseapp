xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
import module namespace functx = "http://www.functx.com";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/dsebaseapp/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/dsebaseapp/templates" at "../modules/app.xql";

let $about := doc($config:app-root||'/project.rdf')/rdf:RDF
let $childCollections := $about//acdh:Collection[acdh:isPartOf]
for $x in $childCollections
    let $collID := data($x/@rdf:about)
    let $collName := tokenize($collID, '/')[last()]
    let $collection-uri := $app:data||'/'||$collName
    let $document-names := xmldb:get-child-resources($collection-uri)
    let $docs := for $item in $document-names
                    let $node := try {
                        doc(string-join(($collection-uri, $item), '/'))
                    } catch * {
                        false()
                    }
                    return $node
    let $map := map{
                "collID": $collID,
                "collectionUri": $collection-uri,
                "collectionEntry": $x,
                "resources": $docs 
            } 
    return $map
