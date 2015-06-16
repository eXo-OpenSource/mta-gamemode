/********************************************
*
*
********************************************/

var SkillTree = function(currentNodeKey) {
    // Define node DOM data
    this._domElements = {};

    // Load current node key
    this.setNode(currentNodeKey);
}

SkillTree.prototype.setNode = function(nodeKey) {
    this._currentNode = nodeKey;
}
