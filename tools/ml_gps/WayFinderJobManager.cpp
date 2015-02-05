#include "WayFinderJobManager.h"
#include <chrono>
#include <iostream>
WayFinderJobManager* WayFinderJobManager::ms_pInstance = nullptr;

WayFinderJobManager::WayFinderJobManager()
{
    ms_pInstance = this;

    m_IsRunning = true;
    m_CalculationThread = std::thread(&WayFinderJobManager::runThread, this);
}

WayFinderJobManager::~WayFinderJobManager()
{
}

void WayFinderJobManager::stop()
{
    m_IsRunning = false;
}

void WayFinderJobManager::runThread()
{
    while (m_IsRunning)
    {
        if (m_JobQueue.empty())
        {
            std::this_thread::yield();
            continue;
        }

        // Lock the mutex, read some data and unlock
        m_JobMutex.lock();
        auto job = m_JobQueue.front();
        m_JobMutex.unlock();

        // Do heavy stuff now
        auto startTime = std::chrono::system_clock::now();
        {
            // Get start and end nodes from points
            auto startNode = m_WayFinder.findNodeClosestToPoint(job.positionFrom);
            auto endNode = m_WayFinder.findNodeClosestToPoint(job.positionTo);

            // Calculate the path and save the result as a list
            std::forward_list<Vector3> result;
            m_WayFinder.calculatePath(startNode, endNode, result);

            // Move calculated path to result cache (will be passed to Lua via the next processGPSEvents call)
            std::lock_guard<std::mutex> l(m_ResultCacheMutex);
            m_ResultCache.push_back(std::make_pair(job.id, std::move(result)));
        }
        std::cout << "Route has been calculated within " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now()-startTime).count() << "ms" << std::endl;

        // Mark the element as processed --> remove it from the queue
        m_JobMutex.lock();
        m_JobQueue.pop_back();
        m_JobMutex.unlock();

        // Do not block the CPU and wait a bit
        std::this_thread::yield();
    }
}

JobId WayFinderJobManager::addJob(WayFinderJob& job)
{
    std::lock_guard<std::mutex> lock(m_JobMutex);

    m_JobQueue.push_back(job);
    job.id = m_JobQueue.size();
    return job.id;
}

const std::list<std::pair<JobId, std::forward_list<Vector3>>>& WayFinderJobManager::getResultCache()
{
    return m_ResultCache;
}

void WayFinderJobManager::clearResultCache()
{
    m_ResultCache.clear();
}
