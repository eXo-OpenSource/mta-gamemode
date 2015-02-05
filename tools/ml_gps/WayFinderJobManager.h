#pragma once
#include <thread>
#include <mutex>
#include <queue>
#include "Vector3.h"
#include "WayFinder.h"

struct WayFinderJob
{
    typedef std::function<void()> Callback;

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

    void addJob(const WayFinderJob& job);

private:
    bool m_IsRunning;
    std::thread m_CalculationThread;
    std::mutex m_JobMutex;
    std::queue<WayFinderJob> m_JobQueue;

    WayFinder m_WayFinder;

    static WayFinderJobManager* ms_pInstance;
};

