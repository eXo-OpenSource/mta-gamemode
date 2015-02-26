#include "WayFinder.h"
#include <limits>

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

WayNode* WayFinder::findNodeClosestToPoint(const Vector3& position)
{
    int areaId = getAreaId(position.x, position.y);
    float minDist = std::numeric_limits<float>().infinity();
    WayNode* minNode = nullptr;

    for (auto& node : m_Nodes[areaId])
    {
        float distSquared = (position.x - node.position.x)*(position.x - node.position.x) + (position.y - node.position.y)*(position.y - node.position.y);

        if (distSquared < minDist)
        {
            minDist = distSquared;
            minNode = &node;
        }
    }

    return minNode;
}

void WayFinder::calculatePath(const WayNode& nodeFrom, const WayNode& nodeTo, std::list<Vector3> result)
{
    // Add start point to result list
    result.push_back(nodeFrom.position);

    const WayNode* currentNode = &nodeFrom;

    // Iterate until we reach the destination node
    while (currentNode != &nodeTo)
    {
        // Find the successor that matches best
        for (auto& neighbour : currentNode->neighbours)
        {
        
        }

    }
    
}
