#pragma once
#include "Vector3.h"
#include <vector>
#include <list>
#include <queue>
#include <set>
#define AREA_COUNT 64

struct WayNode;

struct WayNodeSuccessor
{
	WayNode* node;
	unsigned int distance;
};

struct WayNode
{
    unsigned int id;
    Vector3 position;
    std::vector<WayNodeSuccessor> successors;
};

typedef std::vector<WayNode> NodeList;

class WayFinder
{
public:
    WayFinder();
    ~WayFinder();

    int getAreaId(float x, float y);
    const WayNode& getNodeById(int nodeId);
    WayNode* findNodeClosestToPoint(const Vector3& position);

    void calculatePath(WayNode* nodeFrom, WayNode* nodeTo);

private:
	void ExpandNode(std::priority_queue<WayNode*>& openList, std::set<WayNode*>& closedList, WayNode* start, WayNode* node);
	unsigned int EstimateDistance(WayNode* from, WayNode* to);

private:
    NodeList m_Nodes[AREA_COUNT];
};

