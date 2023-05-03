$sparql = @"
SELECT DISTINCT * WHERE {
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE]". }
  {
    SELECT DISTINCT ?item ?url ?inception WHERE {
      {
        ?item p:P31 ?statement0.
        ?statement0 (ps:P31/(wdt:P279*)) wd:Q7397.
      }
      UNION
      {
        ?item p:P31 ?statement1.
        ?statement1 (ps:P31/(wdt:P279*)) wd:Q6936225.
      }
      ?item wdt:P856 ?url.
      FILTER regex(STR(?url), "https?://[^/]*[^.]+\\.(tk|ml|ga|cf|gq)/.*").
      OPTIONAL {
        ?item wdt:P571 ?inception.
      }
    }
    LIMIT 100
  }
}
"@

Write-Progress -activity "Fetch" -status "Waiting response from Wikidata Query Service..." -percentComplete 0
$x = Invoke-WebRequest https://query.wikidata.org/sparql -Body @{query=$sparql} -Header @{Accept="application/sparql-results+json"}
Write-Progress -activity "Process" -status "Writing..." -percentComplete 75
$x | ConvertFrom-Json | ForEach-Object { $_.results.bindings } | ForEach-Object { ([System.Uri]$_.url.value) } | ForEach-Object { $_.Host } | Set-Content -Encoding UTF8 ./intermediate/known_exempt_hosts.txt
Write-Progress -activity "Finished" -percentComplete 100
