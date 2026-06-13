#import "@preview/academic-alt:0.1.0": *

#show: university-assignment.with(
  title: "Assignment 2",
  subtitle: "COS3721",
  author: "50052578 Jones GWE",
  details: (
    course: "COS3721",
    due-date: "22 June 2026",
  )
)

= Question 1

== a

*Per-core run queues:* Each core has its own waiting line of ready tasks. If a CPU-heavy task such as video encoding is put on one core, it will usually keep running on that same core when it gets CPU time again. This is good for cache use, because some of its data may still be in that core's cache. Short interactive tasks are also put into one of the core queues. They will run quickly if that queue is short. However, if that queue is full of long CPU-heavy work, a short task may wait even while another core has less work @silberschatz2018osc[Section 5.5].

*Shared run queue:* There is one waiting line for all 8 cores. When any core becomes free, it takes a task from the shared queue. This can spread both video encoding tasks and short user request tasks across the machine quite easily. It also means an idle core can quickly find work. The downside is that all cores must use the same queue, and a task may not run on the same core as before @silberschatz2018osc[Section 5.5].

== b

*Per-core run queues - advantages:*

- There is less fighting over one shared queue because each core mostly uses its own queue.
- Cache use is better because a task often returns to the same core and can reuse data already in that core's cache.
- It works well on a multicore system because each core can make many scheduling decisions for itself.

*Per-core run queues - disadvantages:*

- The queues can become uneven. One core may have many tasks while another core is doing nothing.
- The OS needs extra load-balancing code to move tasks between cores.
- A short interactive task can get a poor response time if it is placed behind long CPU-heavy tasks on a busy core.

*Shared run queue - advantages:*

- It is easy to keep all cores busy because an idle core can take the next task from the shared queue.
- The scheduler can see all ready tasks in one place, which makes fairness simpler to implement.
- It avoids the case where one core has an overloaded queue while another core's queue is empty.

*Shared run queue - disadvantages:*

- The shared queue must be protected by locking, otherwise two cores might choose the same task.
- The queue lock can become a bottleneck when many cores are trying to schedule tasks.
- Cache use is worse, because a task may resume on a different core and its cache data may have to be loaded again.

== c

The shared run queue makes balancing easier. If a core is idle, it just takes the next ready task from the common queue. The OS does not first have to move the task from another core's queue. Although with per-core queues balancing is still possible, the OS has to do extra work. It can push tasks away from busy cores, or an idle core can pull a task from a busy core @silberschatz2018osc[Section 5.5].

== d

I would recommend *per-core run queues with load balancing* for this 8-core server.

The shared queue is simpler, but it can become a bottleneck because all 8 cores have to use the same queue. On a busy server, that queue lock could slow down scheduling performance. Per-core queues avoid most of that problem because each core usually works from its own queue @silberschatz2018osc[Section 5.5].

Per-core queues are also better for cache use. Long video encoding tasks often reuse the same data, so it helps if they keep running on the same core. The main problem is fairness, since short user requests must not get stuck behind long CPU-heavy jobs. For that reason, the OS should still balance the queues when some cores are idle and others are overloaded. It should move tasks when needed, but not move them too often, because moving them can waste cache data. This is similar to how Linux CFS does it, where the load is still balanced, but excessive migration is avoided @silberschatz2018osc[Sections 5.5 and 5.7].

= Question 2

TODO

= Question 3

TODO

= Question 4

TODO

= Question 5

TODO

#bibliography("references.bib", title: "References")
