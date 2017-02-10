#include "WayFinder.h"
#include <limits>
#include "Utils.h"

WayFinder::WayFinder()
{
    Utils::processNodes(&this->m_Nodes[AREA_COUNT]);
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

void WayFinder::calculatePath(WayNode* nodeFrom, WayNode* nodeTo)
{
	std::priority_queue<WayNode*> openList; // List that contains all nodes we need to explore
	std::set<WayNode*> closedList; // Nodes that have already been explored

	// Add start node to open list
	openList.push(nodeFrom);

	// Explore nodes until we found the shortest path
	while (!openList.empty())
	{
		// Get and remove closest node
		auto currentNode = openList.top();
		openList.pop();

		// Have we reached the destination?
		if (currentNode == nodeFrom)
			break;

		// Mark current node as closed (to prevent cycles)
		closedList.insert(currentNode);

		// Since we have not found the destination yet, expand successor nodes
		ExpandNode(openList, closedList, nodeFrom, currentNode);
	}
}

void WayFinder::ExpandNode(std::priority_queue<WayNode*>& openList, std::set<WayNode*>& closedList, WayNode* start, WayNode* node)
{
	// Iterate successors
	for (auto& successor : node->successors)
	{
		// Skip this node if we've already expanded it
		if (closedList.find(successor.node) != closedList.end())
			continue;

		// Estimate distance to successor
		unsigned int distanceToSuccessor = EstimateDistance(start, node) + successor.distance;

		// Don't add the successor to the openList twice and ignore if the route is worse than the one we have
		bool contains = Utils::QueueContains(openList, successor.node);
		if (contains && distanceToSuccessor >= EstimateDistance(start, successor.node))
			continue;

		auto realDistance = distanceToSuccessor * EstimateDistance(start, successor.node);
		if (contains)
			openList.pop(); // decreaseKey
		else
			openList.push(successor.node);
	}
}

unsigned int WayFinder::EstimateDistance(WayNode* from, WayNode* to)
{
	auto x = to->position.x - from->position.x;
	auto y = to->position.y - from->position.y;
	auto z = to->position.z - from->position.z;

	return static_cast<unsigned int>(x*x + y*y + z*z);
}
