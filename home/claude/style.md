# Writing Style

When writing documentation, commit messages, comments, or any technical prose, follow the Unix/Bell Labs style below.

## Start With The Job

Open by stating what the thing does, not what it is made of.

**Weak:** The buffer cache is a hash table and list of buffers.

**Stronger:** The buffer cache has two jobs: avoid repeated disk reads, and ensure only one thread modifies a cached block at a time.

Give the reader a reason to care before giving them parts.

## Name The Tension

Say what is hard. Write as if the reader will implement, debug, or operate the system — that pushes prose toward concrete cases, visible invariants, and honest tradeoffs. Useful tensions to surface:

- simple interface vs. expressive power
- concurrency vs. correctness
- performance vs. space use
- caching vs. consistency
- abstraction vs. hidden cost
- compatibility vs. cleaner design

## Avoid Premature Generality

Open with a small case, not the grand theory.

**Weak:** Concurrency control is a broad family of techniques for managing nondeterministic interleavings.

**Stronger:** Two CPUs can update the same list at the same time. A lock prevents this by allowing only one CPU into the update code.

Generalize after the reader has a foothold.

## Use The Reader's Mental Debugger

Good technical prose lets the reader simulate the system. Useful phrases: "Suppose…", "At this point…", "Now the kernel…", "If the machine crashes here…", "On the next call…", "The second thread sees…"

Especially valuable for algorithms, protocols, concurrency, filesystems, and APIs.

## Use Plain Verbs

Prefer direct verbs: reads, writes, stores, records, maps, points, allocates, frees, waits, wakes, retries.

**Prefer:** The log records the blocks that must be written atomically.

**Over:** The logging layer facilitates atomic persistence semantics.

## Do Not Hide The Cost

Every mechanism has a cost. Say it.

- Locks simplify reasoning, but they serialize operations.
- Large blocks improve throughput, but waste space for small files.
- Backtracking is simple, but may explore exponentially many paths.
- Caching avoids disk reads, but requires consistency rules.

## Order: Problem Before Parts

Present in this sequence:

1. What problem the caller has
2. What interface is offered
3. What guarantees the interface gives
4. What algorithm or data structure provides it
5. What tradeoff remains

This prevents diving into implementation before the reader knows what question it answers.

## Expose The Invariant

State what must remain true.

- At most one buffer for a disk block may be modified at a time.
- The on-disk file system must never contain a block that is both allocated and free.
- A file descriptor either refers to an open file object or is unused.
- After a crash, recovery must be able to choose either the old state or the new state.

Once the invariant is visible, the implementation has a purpose.

## Explain Failure Before Fix

Readers remember fixes better after seeing the bug.

1. Here is the obvious design.
2. Here is how it fails.
3. Here is the smallest change that prevents that failure.
4. Here is what the change costs.

The living causal chain: *We wanted X. The obvious way failed because Y. The mechanism Z fixes it, with cost C.*

# Tool Use

## Search Source Syntax Literally

The `grep` tool treats its pattern as a regular expression by default. When
searching for exact source text that contains regex metacharacters, such as
`foo(`, set `literal: true`. Use a regex only when its matching behavior is
needed, and escape metacharacters explicitly.
