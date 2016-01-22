The pop_hedepoch function will extract data epochs time locked to events that certain contain HED tags.

Requirements:
The pop_hedepoch function is dependent on EEGLAB and ctagger.

Setup:
1) Download CTagger from github (https://github.com/VisLab/CTagger/tree/master).
2) Extract CTagger
3) Copy the top-level "ctagger" directory  into the "plugins" directory of eeglab.
4) Run setup.m or eeglab to add the plugin.
5) The plugin is called by clicking on "Extract epochs by tags" under "Tools" (a tagged dataset will need to be loaded)
  
Example (with dataset):
1) Run eeglab
2) Click on "Load existing dataset" under "File"
3) Select "eeglab_data_tagged.set" in the "data" directory
4) Click on "Extract epochs by tags" under "Tools"
5) Type /item/2d shape/rectangle/square for the Time-locking HED tag(s) editbox (click on the ... button to bring up the search bar).
6) Set other arguments and click "Ok"
7) This example will extract 80 epochs (all events with type "square"). 

How To Search and Using the Search Bar:
The tag search uses boolean operators (AND, OR, NOT). Tags separated by commas use the AND operator by default. 
When using the search bar (click on the ... button in the pop_hedepoch main gui) and typing in something there will be a listbox below the search bar containing possible matches. 
Pressing the "up" and "down" arrows on the keyboard while the cursor is in the editbox will move to the next or previous tag in the listbox. 
Pressing "Enter" will select the current tag in the listbox and it will be added to the editbox. 
By default the tag search looks for exact matches. For example, searching for the tag /item/2d shape/rectangle will only return results if this exact tag is found. 
It will not return results containing the tag /item/2d shape/rectangle/square.
If you want to genearlize the search and look for tags that start with a particular prefix then select the prefix checkbox.
For example, searching for the tag /item/2d shape/rectangle will return results with /item/2d shape/rectangle and /item/2d shape/rectangle/square if found.
When done select the "Ok" button and it will take you back to the main gui.    

Search Examples:
Example 1)
/attribute/visual/color/green,/item/2d shape/rectangle/square => /attribute/visual/color/green AND /item/2d shape/rectangle/square

Example 2)
/participant/effect/cognitive/feedback/on reaction time OR /item/2d shape/rectangle/square 

Example 3)
(/attribute/visual/color/green OR /item/2d shape/rectangle/square) NOT /attribute/location/screen/angle/1.5 degrees





