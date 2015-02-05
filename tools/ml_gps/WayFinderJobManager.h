#pragma once
#include <thread>
#include <mutex>
#include <list>
#include <forward_list>
#include "Vector3.h"
#include "WayFinder.h"

typedef unsigned int JobId;

struct WayFinderJob
{
    typedef std::function<void()> Callback;

    JobId id;
    Vector3 positionFrom;
    Vector3 positionTo;
    Callback callback;
};

class WayFinderJobManager
{
public:
    WayFinderJobManager();
    ~WayFinderJobManager();
    static WayFinderJobManager& instance() { return *ms_pInstance; };

    void stop();
    void runThread();

    JobId addJob(WayFinderJob& job);
    
    const std::list<std::pair<JobId, std::forward_list<Vector3>>>& getResultCache();
    void clearResultCache();

private:
    bool m_IsRunning;
    std::thread m_CalculationThread;

    std::mutex m_JobMutex;
    std::list<WayFinderJob> m_JobQueue;

    std::mutex m_ResultCacheMutex;
    std::list<std::pair<JobId, std::forward_list<Vector3>>> m_ResultCache;

    WayFinder m_WayFinder;

    static WayFinderJobManager* ms_pInstance;
};

