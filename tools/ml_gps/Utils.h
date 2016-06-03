#pragma once
#include <algorithm>
#include <queue>

namespace Utils
{
	// http://stackoverflow.com/questions/4484767/how-to-iterate-over-a-priority-queue
	template <class T, class S, class C>
	S& Container(std::priority_queue<T, S, C>& q)
	{
		struct HackedQueue : private std::priority_queue<T, S, C>
		{
			static S& Container(std::priority_queue<T, S, C>& q)
			{
				return q.*&HackedQueue::c;
			}
		};
		return HackedQueue::Container(q);
	}

	template<typename T>
	bool QueueContains(std::priority_queue<T>& queue, const T& element)
	{
		// Get underlying container
		std::vector<T> vector = Container(queue);

		return std::find(vector.begin(), vector.end(), element) != vector.end();
	}
}
