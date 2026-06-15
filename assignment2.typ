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

== a

At time 0, P1 has the highest priority, so it runs first. P3 and P4 both have priority 5, so they use round-robin with a quantum of 8 when they are the highest-priority ready processes. P5 arrives at time 20 with priority 7, so it preempts P3.

#figure(
  image("./assets/assignment2-question2-gantt.svg", width: 100%),
  caption: [Gantt chart for Question 2],
)

== b

Turnaround time is calculated as completion time minus arrival time, as this is equivalent to the interval from submission to completion @silberschatz2018osc[Section 5.2].

#table(
  columns: (25%, 25%, 25%, 25%),
  inset: 5pt,
  stroke: 0.5pt,
  [*Process*], [*Arrival Time*], [*Completion Time*], [*Turnaround Time*],
  [P1], [0], [18], [18],
  [P2], [0], [63], [63],
  [P3], [10], [51], [41],
  [P4], [12], [46], [34],
  [P5], [20], [28], [8],
  [P6], [25], [83], [58],
)

== c

Waiting time is calculated as turnaround time minus burst time, equivalent to the total time spent waiting in the ready queue @silberschatz2018osc[Section 5.2].

#table(
  columns: (25%, 25%, 25%, 25%),
  inset: 5pt,
  stroke: 0.5pt,
  [*Process*], [*Burst*], [*Turnaround Time*], [*Waiting Time*],
  [P1], [18], [18], [0],
  [P2], [12], [63], [51],
  [P3], [15], [41], [26],
  [P4], [10], [34], [24],
  [P5], [8], [8], [0],
  [P6], [20], [58], [38],
)

= Question 3

In CFS, a task with a lower nice value has a higher weight and gets a larger share of CPU time. The scheduler keeps a `vruntime` value for each task and normally chooses the runnable task with the smallest `vruntime`. A higher-priority task's `vruntime` grows more slowly than a lower-priority task's `vruntime` for the same amount of real CPU time @silberschatz2018osc[Section 5.7].

Here *A* has nice value -5, so *A* has higher priority than *B*. *B* has nice value +5, so *B* has lower priority.

== a

#table(
  columns: (25%, 75%),
  inset: 5pt,
  stroke: 0.5pt,
  [*Scenario*], [*How the `vruntime` values change*],
  [*1. A and B are both CPU-bound*],
  [Both tasks are always ready to run. A's `vruntime` grows more slowly because A has the lower nice value and therefore the higher weight. B's `vruntime` grows faster when it runs. CFS will still run B sometimes, because it tries to keep tasks fair, but B will fall behind A in CPU share.],
  [*2. A is I/O-bound and B is CPU-bound*],
  [A often blocks for I/O, so while A is sleeping its `vruntime` does not increase. B keeps using the CPU and its `vruntime` keeps increasing. Since B also has the higher nice value, B's `vruntime` grows relatively quickly. When A becomes runnable again, A will often have a smaller `vruntime` than B.],
  [*3. A is CPU-bound and B is I/O-bound*],
  [A is always ready and keeps using the CPU, but its `vruntime` grows slowly because it has higher priority. B sleeps often, so B's `vruntime` may stay low while it is blocked. When B runs, however, its `vruntime` increases faster than A's because B has lower priority.],
)

== b

#table(
  columns: (35%, 65%),
  inset: 5pt,
  stroke: 0.5pt,
  [*Scenario*], [*Likely scheduling result*],
  [*1. A and B are both CPU-bound*],
  [A is favoured and gets more CPU time. B still runs, but less often or for less total time than A.],
  [*2. A is I/O-bound and B is CPU-bound*],
  [A is likely to be scheduled quickly whenever it wakes up. B will still use the CPU while A is blocked, so B may get most of the total CPU time over a long period.],
  [*3. A is CPU-bound and B is I/O-bound*],
  [A will run for most of the time while B is sleeping. When B wakes up, B may be scheduled quickly if its `vruntime` is smaller, but it will usually run only briefly before blocking again.],
)

= Question 4

TODO

= Question 5

TODO

#bibliography("references.bib", title: "References")
