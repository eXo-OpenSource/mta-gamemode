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
            auto startNode = m_WayFinder.findNodeClosestToPoint(job.positionFrom);
            auto endNode = m_WayFinder.findNodeClosestToPoint(job.positionTo);

            m_WayFinder.calculatePath(startNode, endNode);
        }
        std::cout << "Route has been calculated within " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now()-startTime).count() << "ms" << std::endl;

        // Mark the element as processed --> remove it from the queue
        m_JobMutex.lock();
        m_JobQueue.pop();
        m_JobMutex.unlock();

        std::this_thread::yield();
    }
}

void WayFinderJobManager::addJob(const WayFinderJob& job)
{
    std::lock_guard<std::mutex> lock(m_JobMutex);

    m_JobQueue.push(job);
}
