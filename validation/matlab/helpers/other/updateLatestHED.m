function updateLatestHED()
HED = 'HED.xml';
wikiPath = [tempdir 'temp.mediawiki'];
hedAttributes = 'HEDMaps.mat';
hedPath = which(HED);
hedMapsPath = strrep(hedPath, HED, hedAttributes);
wiki2XML(wikiPath, hedPath);
delete(wikiPath);
hedMaps = mapHEDAttributes(hedPath); %#ok<NASGU>
save(hedMapsPath, 'hedMaps');
end