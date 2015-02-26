#pragma once
#include "Vector3.h"
#include <vector>
#include <list>
#define AREA_COUNT 64

struct WayNode
{
    int id;
    Vector3 position;
    std::vector<std::pair<int, int>> neighbours; // TODO: Optimize later
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
    void calculatePath(const WayNode& nodeFrom, const WayNode& nodeTo, std::list<Vector3> result);

private:
    NodeList m_Nodes[AREA_COUNT];
};

