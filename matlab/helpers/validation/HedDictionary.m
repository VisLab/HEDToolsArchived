classdef HedDictionary
    %HEDDICTIONARY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DEFAULT_UNIT_ATTRIBUTE = 'default';
        EXTENSION_ALLOWED_ATTRIBUTE = 'extensionAllowed';
        TAG_DICTIONARY_KEYS = {'default', 'extensionAllowed', ...
            'isNumeric', 'position', 'predicateType', 'recommended', ...
            'required', 'requireChild', 'tags', 'takesValue', 'unique', ...
            'unitClass'};
        TAGS_DICTIONARY_KEY = 'tags';
        TAG_UNIT_CLASS_ATTRIBUTE = 'unitClass';
        UNIT_CLASS_ELEMENT = 'unitClass';
        UNIT_CLASS_UNITS_ELEMENT = 'units';
        UNIT_CLASS_DICTIONARY_KEYS = ['default', 'units'];
        UNITS_ELEMENT = 'units';
        VERSION_ATTRIBUTE = 'version';
        dictionaries = None;
        root_element = None;
    end
    
    methods
        function obj = HedDictionary(hed_xml_file_path)
            %         Constructor for the Hed_Dictionary class.
            %         Parameters
            %         ----------
            %         hed_xml_file_path: string
            %             The path to a HED XML file.
            %         Returns
            %         -------
            %         HedDictionary
            %             A Hed_Dictionary object.
            obj.root_element = findRootElement(hed_xml_file_path);
            obj.dictionaries = populateDictionaries();
        end % HedDictionary
        
    end % public methods
    
    methods(Static)
        function rootElement = findRootElement(hed_xml_file_path)
            %         Parses a XML file and returns the root element.
            %         Parameters
            %         ----------
            %         hed_xml_file_path: string
            %         The path to a HED XML file.
            %         Returns
            %         -------
            %         RestrictedElement
            %         The root element of the HED XML file.
            tree = xmlread(hed_xml_file_path);
            rootElement = tree.getDocumentElement;
        end
    end % static methods
    
end % HedDictionery