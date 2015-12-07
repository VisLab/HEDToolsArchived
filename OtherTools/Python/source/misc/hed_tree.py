class HED_tree_node:
    'Nodes for HED tree'
    def __init__(self,name):
        self.name = name
        self.child_dict = {}

    def add_child(self,child_name):
        self.child_dict[child_name] = HED_tree_node(child_name)
        return self.child_dict[child_name]
        
    def add_child_node(self,child):
        self.child_dict[child.name] = child
        return self.child_dict[child.name]
        
    def get_child(self,child_name):
        try:
            return self.child_dict[child_name]
        except KeyError:
            return None
        
class HED_tree:
    'A tree representation of HED hierarchy which can be used to verify hed strings'
    root_name = "HED_tree_root"
    quantity = "isnum"
    
    def __init__(self):
        'constructor'
        self.root = HED_tree_node(HED_tree.root_name)
        
    def add_node(self,node_name,parent_list):
        """
        adds node to tree with place in hierarchy given by parent_list, if no parents in list, then node will have parent root
        parent_list is an ordered list that specifies a path starting at parent_list[0] and going to paren_list[len(parent_list) - 1]
        returns node on successful addition; None otherwise.
        """
        parent = self.root
        for parents in parent_list:
            parent = parent.get_child(parents)
            if(parent == None):
                return None
    
        return parent.add_child(node_name)
    
    def verify_node(self,lineage):
        """
        lineage is an ordered list which describes a path from root to node,(starts with first child of root and ends with node to be verified)
        returns true if node with given lineage is in tree, false otherwise
        """
        if(lineage == []):
            return False
        
        node = self.root
        leaf = lineage.pop()
        
        for parent in lineage:
            node = node.get_child(parent)
            if(node == None):
                lineage.append(leaf)
                return False
        
        lineage.append(leaf)
        if(node.get_child(leaf)):
            return True
#        Could possibly be used to correctly identify quantity based children
#        if(node.get_child(quantity)):
#            if(re.search(r'\d',leaf)):
#                return True
#            else:
#                return False
            
        leaf_parent = node.name
        if(leaf_parent == "Description" or leaf_parent == "Long name" or leaf_parent == "Label"):
            return True
        
        return False
