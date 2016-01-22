function wikiVersion = downloadLatestHED()
wikiURL = 'https://raw.githubusercontent.com/wiki/BigEEGConsortium/HED/HED-Schema.mediawiki';
wikiPath = [tempdir 'temp.mediawiki'];
websave(wikiPath, wikiURL);
wikiVersion = findWikiHEDVersion(wikiPath);
end

