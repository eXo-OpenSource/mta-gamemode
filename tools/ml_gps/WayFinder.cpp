#include "WayFinder.h"

WayFinder::WayFinder()
{
}

WayFinder::~WayFinder()
{
}

int WayFinder::getAreaId(float x, float y)
{
    return (int)((y + 3000)/750)*8 + (int)((x + 3000)/750);
}

const WayNode& WayFinder::getNodeById(int nodeId)
{
    int areaId = static_cast<int>(nodeId / 65536);
    return m_Nodes[areaId][nodeId];
}

const WayNode& WayFinder::findNodeClosestToPoint(const Vector3& position)
{
    int areaId = getAreaId(position.x, position.y);
    float minDist = 9999999.9f;
    WayNode minNode;

    for (auto& node : m_Nodes[areaId])
    {
        float dist = (position.x - node.position.x)*(position.x - node.position.x) + (position.y - node.position.y)*(position.y - node.position.y);

        if (dist < minDist)
        {
            minDist = dist;
            minNode = node;
        }
    }

    return minNode;
}

void WayFinder::calculatePath(const WayNode& nodeFrom, const WayNode& nodeTo, std::forward_list<Vector3> result)
{
    
    WayNode currentNode = nodeFrom;
    /*while (currentNode != nodeTo)
    {
        
        for (auto iter = currentNode.neighbours.begin(); iter != currentNode.neighbours.end(); ++iter)
        {
            auto successor = getNodeById(iter->first);
            //auto successor_g = 


        }

    }*/


}