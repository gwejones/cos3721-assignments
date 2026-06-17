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

== a

Checking the semaphore value before calling `wait()` is unsafe because the check and the `wait()` call are two separate actions. Another process can run between them and change the semaphore. This is a race condition.

The important point is that the test of the semaphore value and the decrement of the value must happen atomically. The textbook says that the semaphore value must be modified atomically, and that `wait(S)` must test and possibly decrement `S` without interruption @silberschatz2018osc[Section 6.6].

So this code:

```c
if (getValue(&sem) > 0)
    wait(&sem);
```

does not really make `wait()` safe or non-blocking. The value returned by `getValue()` may already be old by the time `wait()` is called.

== b

One possible sequence is:

#enum(
  [The semaphore starts at `1`.],
  [`P1` calls `getValue(&sem)` and sees `1`. It is about to call `wait(&sem)`, but it is preempted.],
  [`P2` now runs. It also calls `getValue(&sem)` and sees `1`.],
  [`P2` calls `wait(&sem)`. Since the semaphore is still available, `wait()` decrements it to `0`, and `P2` enters the critical section.],
  [`P1` runs again and calls `wait(&sem)`. But the semaphore is now `0`, so `P1` blocks.],
)

This is not what the developer intended. `P1` checked the value first because it wanted to avoid blocking, but it still blocked because the value changed after the check. If the program used the result of `getValue()` as permission to enter the critical section, the situation would be worse, because both processes could think the semaphore was available.

== c

A safer approach is not to check the value separately. Since the alternative should prevent blocking, the process should use one atomic non-blocking acquire operation, such as `trywait()`:

```c
if (trywait(&sem)) {
    /* critical section */
    signal(&sem);
} else {
    /* dont enter the critical section; try again later */
}
```

Here `trywait()` must test the semaphore and decrement it as one atomic operation. If the semaphore is available, the process acquires it and enters the critical section. If it is not available, the process immediately returns failure instead of blocking. This gives mutual exclusion because no process enters the critical section unless it has actually acquired the semaphore. This kind of atomic test-and-update can be built using hardware support such as compare-and-swap @silberschatz2018osc[Sections 6.4 and 6.6].

= Question 5

For this question I will assume that `compare_and_swap(value, expected, new_value)` returns the old value of `value`, as per the textbook example. The textbook explains that compare-and-swap checks a value and changes it as one atomic operation @silberschatz2018osc[Section 6.4.2].

== a

The lock should be initialized to `0` because the question defines `0` as unlocked and `1` as locked. It must be initialized before any thread can use it.

```c
void init(lock *m) {
    m->available = 0;
}
```

== b

The `acquire()` function can keep trying until it changes `available` from `0` to `1`.

```c
void acquire(lock *m) {
    while (compare_and_swap(&m->available, 0, 1) != 0) {
        ; /* busy wait */
    }
}
```

If `available` is `0`, the thread changes it to `1` and enters the critical section. If `available` is already `1`, another thread owns the lock, so the thread keeps waiting. This is the same basic idea as the textbook's mutual-exclusion example using compare-and-swap @silberschatz2018osc[Section 6.4].

== c

The `release()` function unlocks the mutex by setting `available` back to `0`.

```c
void release(lock *m) {
    m->available = 0;
}
```

Only the thread that acquired the lock should call `release()`. After this assignment, another waiting thread can successfully acquire the lock.

== d

`compare_and_swap()` is important because it combines the check and the update into one indivisible operation. Without it, two threads could both see `available == 0` before either one changes it to `1`. They could then both enter the critical section, which breaks mutual exclusion.

With `compare_and_swap()`, only one thread can successfully change `available` from `0` to `1`. If two threads try at the same time, the hardware runs the operations one at a time in some order, so one succeeds and the other sees that the lock is already taken. This is why atomic hardware instructions are used to build mutex locks @silberschatz2018osc[Sections 6.4 and 6.5].

= Question 6

== a

Operating systems provide different locks because the synchronization problems that an operating system has to solve are not all the same. A single universal lock would either be too slow or too restrictive to apply to all situations.

Some critical sections are extremely short, so it can be cheaper for a thread to spin briefly than to be put to sleep and later woken up. Other critical sections may take longer, especially if a thread may wait for I/O, so blocking is better than wasting CPU time. Some problems are not just about one thread entering a critical section; they involve counting a limited number of resources, or making a thread wait until some condition becomes true.

So the OS uses different mechanisms for different needs. Spinlocks for very short waits, mutex locks for ordinary mutual exclusion, semaphores for counting and resource limits, and condition variables for waiting on a state change @silberschatz2018osc[Sections 6.5, 6.6.1, and 6.7.1].

== b

=== Spinlock

A spinlock would be used when a server thread needs to update a very small shared value, like perhaps a counter or a pointer, and the lock will be held for only a few cycles.

It is needed because it avoids the overhead of putting the thread to sleep and waking it again. This only makes sense for very short waits, otherwise the thread wastes CPU time while spinning @silberschatz2018osc[Section 6.5].

=== Mutex lock

A mutex lock would be used when threads access a shared structure such as a buffer. Only one thread should modify that structure at a time.

It is needed because it gives mutual exclusion. A thread must acquire the lock before entering the critical section and release it afterwards, preventing two threads from corrupting the shared data @silberschatz2018osc[Section 6.5].

=== Semaphore

A semaphore would be used when the server has a limited pool of resources, such as some database connections. Many threads may request a resource, but only up to the available limit may use it.

It is needed because a counting semaphore can be initialized to the number of available resources. Each thread performs `wait()` before using one resource and `signal()` when it releases it. This prevents too many threads from using the limited resource at once @silberschatz2018osc[Section 6.6.1].

=== Condition variable

A condition variable could be used when threads wait for new client requests to be placed into a shared work queue. When the queue is empty, workers should not keep checking it in a loop.

It is needed because it lets a worker sleep until another thread signals that the queue is no longer empty. It is useful for waiting for a condition to become true, not just for locking a data structure @silberschatz2018osc[Section 6.7.1].

= Question 7

TODO

= Question 8

TODO

#bibliography("references.bib", title: "References")
