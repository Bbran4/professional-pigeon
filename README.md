# PROFESSIONAL PIGEON

> **A 2D incremental idle game about feeding pigeons, building a flock, and turning an ordinary park into an increasingly ridiculous pigeon ecosystem.**

---

## Overview

**PROFESSIONAL PIGEON** is a 2D single-player incremental idle game built around a deliberately simple idea:

**Give pigeons food. Watch what happens. Make it bigger.**

The player does **not** directly control a pigeon.

Instead, the player manages the conditions that make the park come alive.

You begin with a quiet city park, a small supply of basic food, and a single pigeon.

The player starts a day, provides food, and watches the pigeon arrive, fly down from a tree, search for food, eat, and generate resources.

Those resources can then be spent on upgrades that make the next day more productive.

More food.

More pigeons.

Faster feeding.

New food sources.

New places for pigeons to gather.

Water baths.

Pigeon houses.

New bird types.

New park features.

Eventually, the quiet park becomes a bustling pigeon ecosystem.

The player is not the hero.

**The pigeons are the show.**

---

# Core Concept

Professional Pigeon is built around a short, repeatable incremental loop:

**Start Day → Provide Food → Pigeons Arrive → Pigeons Eat → Earn Resources → Buy Upgrades → Start Next Day**

The player mostly interacts through buttons and menus.

The fun comes from watching the world respond.

A successful upgrade should not only make a number larger. It should make the park **look and behave differently**.

---

# The Day Loop

Each run represents one **day in the park**.

The initial day lasts **60 seconds**.

At the beginning of a day, the player starts the run.

During the day:

1. Food is introduced into the park.
2. Pigeons notice the food.
3. Pigeons arrive from the surrounding environment.
4. Pigeons fly, land, walk, search and eat.
5. Eating generates resources.
6. More pigeons can arrive as the player's upgrades improve.
7. The park becomes increasingly active.
8. The day ends when the timer reaches zero.

The player then receives a results screen showing what happened.

Example:

**DAY 7 COMPLETE**

- Pigeons attracted: 14
- Food eaten: 23
- Points earned: 184
- Maximum pigeons present: 11
- New unlocks available

The player spends their accumulated resources on upgrades and starts the next day.

---

# The Important Part: Watching Numbers Go Up

Incremental games work because progression is both **numerical and visible**.

Professional Pigeon should make that progression obvious.

The player might begin with:

> **1 pigeon**

Then:

> **3 pigeons**

Then:

> **8 pigeons**

Then:

> **20 pigeons**

The numbers increase, but so does the visual activity on screen.

One pigeon eating a piece of bread is the beginning.

Twenty pigeons fighting over a pile of food is progress.

The park itself becomes the progress bar.

---

# The Park

The first environment is a **city park**.

The initial view should be a relatively contained 2D scene rather than a traditional platforming level.

The player character may be visible, such as a person sitting on a park bench, but the character is not directly controlled.

The player is essentially the unseen manager of the park.

The park can contain:

- Trees
- Grass
- Paths
- Benches
- Food
- Bird feeders
- Water
- Pigeon houses
- Decorative objects
- Background buildings
- Other park visitors
- Pigeons

The initial park should remain deliberately simple.

New systems should be introduced as the player progresses.

---

# Pigeons

Pigeons are the heart of the game.

They should behave like autonomous little creatures rather than animated counters.

A pigeon should be capable of simple natural behaviours such as:

- Flying down from a tree
- Landing
- Walking
- Looking for food
- Pecking at food
- Drinking
- Bathing
- Idling
- Looking around
- Flying away
- Returning to a preferred area
- Reacting to other pigeons

The player should be able to sit back and watch the flock develop naturally.

---

# Pigeon Behaviour

The first pigeon prototype should be simple.

A basic pigeon might follow a state-driven behaviour loop:

**Perch → Notice Food → Fly Down → Land → Search → Eat → Idle → Fly Away**

As the game develops, additional behaviours can be introduced.

Examples:

**Food nearby**

> Walk toward it.

**Another pigeon nearby**

> Join the group.

**Water available**

> Drink or bathe.

**Too much activity**

> Fly away.

**Pigeon house available**

> Return to it.

The goal is not to create a complicated simulation.

The goal is to create **believable, entertaining behaviour**.

---

# Pigeon Population

The first major progression goal is simply to attract more pigeons.

Early progression might look like:

### Stage 1

**1 pigeon**

One food source.

### Stage 2

**3 pigeons**

More food becomes available.

### Stage 3

**5-10 pigeons**

Multiple feeding opportunities.

### Stage 4

**10-20 pigeons**

The park starts to feel busy.

### Stage 5

**20+ pigeons**

The player begins managing an actual flock.

Population growth should be visible and satisfying.

---

# Food

Food is the primary driver of the early game.

The first food source is intentionally simple:

## Bread

Bread can be spawned into the park during a day.

Pigeons detect it, move toward it and eat it.

Eating bread generates the player's primary run resource.

Later, additional food types can be unlocked.

Possible food sources include:

- Bread
- Seeds
- Grain
- Fruit
- Crumbs
- Pastries
- Other increasingly valuable food

Different foods can attract different pigeons or produce different rewards.

---

# Resource Progression

Resources should remain simple and understandable.

The player should always know:

**What am I earning?**

**What am I spending it on?**

**What does this unlock?**

The initial game should use as few currencies as possible.

Possible resources include:

### Points

The main progression currency generated by pigeon activity.

### Coins

A secondary persistent currency that can eventually be used for larger purchases and systems.

### Food

The physical resource placed into the park.

Additional currencies should only be introduced when they create a meaningful new decision.

The game should not become a spreadsheet with pigeons painted on it.

---

# Upgrades

Upgrades are the main source of long-term progression.

The important principle is:

> **Upgrades should change what happens in the park, not merely increase numbers.**

Examples:

### More Food

Increase the amount of food provided during each day.

### Faster Feeding

Reduce the time between food being provided.

### Better Food

Unlock food that produces more resources.

### More Pigeons

Increase the number of pigeons that can be attracted.

### Larger Feeding Area

Give pigeons more places to gather.

### Bird Feeder

Create a permanent feeding location.

### Water Bath

Introduce drinking and bathing behaviour.

### Pigeon House

Give pigeons a place to return to.

### Bigger Park

Expand the available environment.

Each upgrade should ideally produce an observable change.

---

# Unlock Progression

The player gradually transforms the park.

A possible progression path:

**Bread**

↓

**More Bread**

↓

**More Pigeons**

↓

**Bird Feeder**

↓

**Seeds**

↓

**Water Bath**

↓

**Pigeon House**

↓

**New Food**

↓

**New Pigeon Types**

↓

**New Park Features**

↓

**New Park**

The exact progression will be discovered through prototyping and balancing.

---

# Visual Progression

Visual progression is one of the game's most important design pillars.

The player should be able to look at the park and immediately see that their upgrades matter.

Early:

> Empty park. One pigeon.

Later:

> Food scattered across the grass.

Later:

> Several pigeons feeding.

Later:

> Bird feeders and water baths.

Later:

> Pigeon houses.

Later:

> A crowded park full of birds.

The player's park should gradually become a living representation of their progress.

---

# The Player

There is no traditional player-controlled character.

A person may be visible in the environment, for example sitting on a bench and throwing food, but this is presentation rather than direct gameplay control.

The player's interaction is primarily:

- Start Day
- Buy Upgrade
- Unlock Feature
- Start Next Day
- Manage persistent progression

There is no platforming.

There is no direct pigeon movement control.

There is no traditional combat.

There is no requirement for the player to manually collect every resource.

The player creates the conditions.

**The pigeons do the rest.**

---

# Idle Gameplay

The game should remain satisfying even when the player is doing very little.

The player presses a button.

The park reacts.

Numbers increase.

Pigeons move around.

Resources accumulate.

The player buys an upgrade.

The next day becomes more productive.

The loop repeats.

The goal is to create the pleasant incremental feeling of:

> **"Just one more upgrade."**

---

# Automation

Automation should gradually reduce the amount of manual intervention required.

For example:

### Beginning

Player starts the day.

Food is provided manually.

### Later

Food is automatically provided at intervals.

### Later

Multiple food sources activate automatically.

### Later

Pigeons naturally return to the park.

### Eventually

The park becomes a largely self-sustaining ecosystem.

Automation is not about removing the game.

It is about making the player's growing ecosystem feel increasingly powerful.

---

# The Skill Tree

The existing progression system will remain an important part of the game.

The skill tree should be adapted to the new idle structure.

Rather than upgrading a player character, upgrades should affect:

- Food production
- Food spawn quantity
- Food spawn frequency
- Pigeon attraction
- Pigeon population
- Feeding efficiency
- Resource generation
- Park features
- Day length
- Automation
- New pigeon types
- New environments

The skill tree should provide meaningful choices rather than simply being a list of percentage increases.

---

# Day Length

The initial day lasts **60 seconds**.

Later upgrades can increase the length of a day.

For example:

**60 seconds**

↓

**75 seconds**

↓

**90 seconds**

↓

**2 minutes**

↓

**3 minutes**

↓

**5 minutes**

Longer days allow more activity to occur and make stronger upgrades more valuable.

Day length should be balanced carefully so that increasing it feels useful without simply making the game slower.

---

# Natural Pigeon Activity

A major development goal is making pigeons enjoyable to watch.

Pigeons should not simply appear directly on top of food.

A better sequence is:

**Pigeon perched in tree**

↓

**Notices food**

↓

**Flies down**

↓

**Lands**

↓

**Walks toward food**

↓

**Searches**

↓

**Eats**

↓

**Looks around**

↓

**Returns to activity**

Small behaviours like these are important.

The player is spending much of their time watching the park.

The animation and behaviour therefore need to carry part of the game's entertainment.

---

# Events and Reactions

Once the core pigeon-and-food loop works, the park can gain additional interactions.

Possible future systems include:

- Cats
- Dogs
- Children
- Park visitors
- Other birds
- Rain
- Wind
- Special food drops
- Crowds
- Park events
- Seasonal changes

These should be added only after the basic loop is fun.

The rule is simple:

> **Do not add complexity just because we can.**

---

# Multiple Parks

The first park is the tutorial environment and the foundation of the game.

Later, new locations can introduce different visual themes and gameplay opportunities.

Possible locations:

- City Park
- Town Square
- Market
- Farm
- Train Station
- Harbour
- Rooftops
- Castle Grounds
- Countryside

Each location should introduce something genuinely new.

A new background alone is not enough.

---

# Pigeon Types

Different pigeon types can eventually be introduced.

Examples:

- Common Pigeon
- Fat Pigeon
- Fast Pigeon
- Hungry Pigeon
- Fancy Pigeon
- Messenger Pigeon
- Giant Pigeon
- Rare Pigeon

Different pigeon types may have different behaviours or resource bonuses.

However, this system should come **after** the basic pigeon loop has been proven.

---

# Comedy

The game should be humorous without requiring constant jokes.

The comedy should come from the escalation of an otherwise ordinary park.

At the beginning:

> One person feeds one pigeon.

Later:

> A dozen pigeons are aggressively occupying the park.

Later still:

> There is a dedicated pigeon house.

Eventually:

> The player has somehow created a pigeon civilization.

The humour comes from treating increasingly absurd pigeon activity as completely normal.

---

# Long-Term Progression

The long-term goal is not simply to produce larger numbers.

It is to transform the park.

The player starts with:

**A person.**

**A bench.**

**A pigeon.**

**Some bread.**

Eventually they have:

**A thriving pigeon ecosystem.**

**Multiple food sources.**

**Dedicated pigeon facilities.**

**Large flocks.**

**Multiple parks.**

**Different pigeon species.**

**A ridiculous amount of food.**

The progression should always feel tangible.

---

# Art Direction

The game will use a stylized 2D art style.

The visual direction should prioritize:

- Clear silhouettes
- Expressive pigeons
- Readable environments
- Strong animation
- Humorous details
- Warm, inviting environments
- Easy-to-understand UI

Pigeons should be visually appealing and immediately readable.

The park should be interesting enough to watch without overwhelming the player.

---

# Technical Direction

## Engine

Godot 4.x

## Language

GDScript

## Game Type

2D Single-Player Incremental Idle Game

## Presentation

A contained 2D park scene viewed from the side.

The game is no longer designed around traditional side-scrolling platformer movement.

The camera should primarily frame the park as a stage on which the autonomous systems play out.

---

# Architecture

The project should be organized around modular systems.

```text
Game
├── Park
│   ├── Environment
│   ├── Food
│   ├── Water
│   └── Facilities
│
├── Pigeons
│   ├── Pigeon Data
│   ├── Pigeon AI
│   ├── Pigeon States
│   ├── Pigeon Behaviour
│   └── Pigeon Types
│
├── Resources
│   ├── Food
│   ├── Points
│   └── Coins
│
├── Day System
│   ├── Day Timer
│   ├── Day Start
│   ├── Day End
│   └── Day Results
│
├── Spawning
│   ├── Food Spawning
│   ├── Pigeon Spawning
│   └── Future Entity Spawning
│
├── Progression
│   ├── Upgrades
│   ├── Unlocks
│   ├── Skill Tree
│   └── Persistent Progress
│
├── UI
│   ├── Run HUD
│   ├── Upgrade Screen
│   ├── Day Results
│   └── Progress Displays
│
└── Persistence
    ├── Save Data
    └── Load Data
```

The exact architecture will evolve during development.

---

# Data-Driven Design

Where practical, game content should remain data-driven.

Examples:

- Food types
- Pigeon types
- Pigeon stats
- Spawn quantities
- Spawn intervals
- Upgrade definitions
- Unlock requirements
- Park facilities
- Day modifiers
- Resource values

This allows new content to be added without rewriting the core systems.

The existing collectible data model can be repurposed where appropriate rather than discarded unnecessarily.

---

# Persistence

Persistent progression is important because the game is built around repeated days.

The game should save and load information such as:

- Total resources
- Purchased upgrades
- Unlocked food
- Unlocked pigeon types
- Unlocked park features
- Day progression
- Best day results
- Park progression
- Future locations
- Other permanent unlocks

The player's progress should survive between sessions.

---

# What We Keep From the Existing Project

The previous prototype already contains useful systems and concepts.

The following can be retained or adapted:

- Resource data
- Collectible data model
- Data-driven resource definitions
- Progression system
- Skill tree
- Upgrade system
- Persistent progression concepts
- Pigeon class
- Pigeon state machine architecture
- Spawn manager concepts
- Run timer
- Run HUD
- Run results
- Save/load architecture

The purpose of the redesign is **not** to throw away working systems unnecessarily.

Instead, systems should be adapted to support the new idle park loop.

---

# What We Remove or Replace

The previous game was designed as a side-scrolling platformer with direct player movement.

Those systems are no longer central.

The following should be removed or substantially redesigned:

- Direct player movement
- Player controller
- Player platforming
- Manual pigeon control
- Player-centric interaction
- Platforming level design
- Character traversal as the primary gameplay loop

The player should no longer need to move around the world to make the game work.

---

# Prototype Development Order

The first goal is **not** to build the entire game.

The first goal is to prove that watching pigeons create an increasingly productive park is fun.

## Phase 1: Park Scene

Create a simple park.

Goals:

- Park background
- Ground
- Tree
- Bench
- Basic camera framing
- Placeholder food
- Placeholder pigeon

---

## Phase 2: One Pigeon

Build the simplest believable pigeon.

Goals:

- Perch
- Fly
- Land
- Walk
- Find food
- Eat
- Idle
- Leave

The pigeon should be autonomous.

The player should not control it.

---

## Phase 3: First 60-Second Day

Implement the core day loop.

Goals:

- Start Day button
- 60-second timer
- Food spawning
- Pigeon spawning
- Food consumption
- Points generation
- Day ending
- Results screen

At this point the game should already be playable.

---

## Phase 4: More Pigeons

Make population growth visible.

Goals:

- Increase pigeon spawn quantity
- Prevent excessive overlap
- Allow multiple pigeons to eat
- Improve natural movement
- Make a growing flock visually satisfying

The first major target is:

> **Can one pigeon become twenty pigeons in a way that feels satisfying?**

---

## Phase 5: First Upgrades

Introduce the smallest possible progression system.

Initial upgrades might include:

- More Food
- More Pigeons
- Faster Food
- Longer Day

The player should immediately see the effect of purchases.

---

## Phase 6: Park Features

Introduce the first environmental unlocks.

Examples:

- Bird Feeder
- Water Bath
- Pigeon House

Each feature should introduce new visual activity.

---

## Phase 7: More Food

Introduce additional food types.

Goals:

- Food unlocks
- Different food values
- Different spawn rates
- Different pigeon preferences

---

## Phase 8: Better Pigeon Behaviour

Expand the autonomous simulation.

Goals:

- Pigeon flocking
- Food preferences
- Perching
- Bathing
- Returning home
- Simple reactions

---

## Phase 9: Secondary Systems

Only once the core loop is proven should we introduce:

- Other birds
- Cats
- Dogs
- Humans
- Park events
- Multiple currencies
- Multiple locations

---

# Development Principles

## Prove the Loop First

The fundamental loop is:

```text
Start Day
    ↓
Provide Food
    ↓
Pigeons Arrive
    ↓
Pigeons Eat
    ↓
Earn Resources
    ↓
Buy Upgrade
    ↓
Start Next Day
```

If this is not satisfying with placeholder art, additional content will not fix it.

---

## Visual Progression Matters

Numbers should increase, but the world should change too.

A good upgrade should ideally produce something the player can see.

---

## Keep the Player Out of the Way

The player is the manager, not the character performing every task.

The less the player has to manually control, the more important the simulation becomes.

---

## Pigeons Are the Content

The park exists to give the pigeons somewhere interesting to behave.

Pigeons should therefore receive more attention than complicated menus.

---

## Avoid Meaningless Number Inflation

Large numbers are satisfying.

But numbers alone are not enough.

Progression should unlock:

- More pigeons
- More food
- New behaviours
- New facilities
- New pigeon types
- New environments
- New interactions
- More automation

---

## Every Upgrade Should Ask a Question

Good upgrades make the player think:

> "What happens if I buy this?"

Not:

> "This gives me another 5% because the spreadsheet says so."

---

## Keep Complexity Earned

Cats, dogs, children, other birds and elaborate park systems can come later.

The first version only needs:

**Food.**

**Pigeons.**

**Points.**

**Upgrades.**

**A 60-second day.**

If that is fun, we have something worth building.

---

# Development Status

The project is currently being reworked from its original side-scrolling pigeon game into an **incremental idle park simulation**.

## Core Loop

- [x] 60-second run/day concept
- [ ] Start Day
- [ ] Food spawning
- [ ] Autonomous pigeon arrival
- [ ] Pigeon eating
- [ ] Resource generation
- [ ] Day completion
- [ ] Day results
- [ ] Upgrade between days

## Pigeons

- [x] Existing pigeon class
- [x] Existing state-machine foundation
- [ ] Autonomous pigeon behaviour
- [ ] Flying from tree
- [ ] Landing
- [ ] Food seeking
- [ ] Eating
- [ ] Natural idle behaviour
- [ ] Multiple simultaneous pigeons
- [ ] Pigeon population progression

## Resources

- [x] Existing data-driven resource/collectible foundation
- [ ] Adapt resources to idle production
- [ ] Food spawning
- [ ] Food consumption
- [ ] Points generation
- [ ] Persistent currency
- [ ] Additional food types

## Progression

- [x] Existing skill/progression system
- [x] Existing upgrade concepts
- [ ] Rework upgrades around park progression
- [ ] Food quantity upgrades
- [ ] Pigeon quantity upgrades
- [ ] Day length upgrades
- [ ] Automation upgrades
- [ ] Park feature unlocks
- [ ] New food unlocks
- [ ] Pigeon type unlocks

## Park

- [ ] First park environment
- [ ] Tree
- [ ] Bench
- [ ] Feeding area
- [ ] Bird feeder
- [ ] Water bath
- [ ] Pigeon house
- [ ] Expanded park
- [ ] Additional locations

## UI

- [ ] Day timer
- [ ] Resource display
- [ ] Pigeon population display
- [ ] Start Day button
- [ ] Day Results screen
- [ ] Upgrade screen
- [ ] Persistent progression display

## Persistence

- [ ] Save system
- [ ] Load system
- [ ] Persistent upgrades
- [ ] Persistent unlocks
- [ ] Persistent resources
- [ ] Best day statistics

## Future

- [ ] Other pigeon types
- [ ] Other birds
- [ ] Cats
- [ ] Dogs
- [ ] Humans
- [ ] Park events
- [ ] Multiple parks
- [ ] Advanced automation
- [ ] Long-term prestige/progression

---

# First Playable Target

The first genuinely playable version should be tiny.

### The screen

A park.

A tree.

A bench.

A person sitting on the bench.

### The button

**START DAY**

### The day

60 seconds.

### The food

Bread.

### The pigeon

One pigeon.

### The behaviour

**Tree → Fly Down → Land → Find Bread → Eat → Earn Points**

### The upgrade

**More Bread**

Then repeat.

The next goal is to make:

**1 pigeon → 3 pigeons → 5 pigeons → 10 pigeons → 20 pigeons**

feel satisfying.

If watching that happen is fun, we have the foundation of Professional Pigeon.

---

# Long-Term Vision

Professional Pigeon should eventually let the player look at their original quiet park and realize how absurdly far it has come.

At the beginning:

**One bench.**

**One person.**

**One pigeon.**

**One piece of bread.**

Later:

**A flock.**

**Multiple feeding areas.**

**Water baths.**

**Pigeon houses.**

**Different foods.**

**Different pigeon types.**

Eventually:

**A thriving pigeon ecosystem spread across multiple locations.**

The player is not building a kingdom because they control every pigeon.

They are building an ecosystem because they have learned how to make pigeons come back.

And then they make more pigeons come back.

And more.

And more.

Until the park belongs to them.

Not officially.

But everyone knows.

---

# The Design Goal

The ultimate feeling we want is:

> **"I wonder what happens if I upgrade this."**

Then:

> **"That's more pigeons."**

Then:

> **"That's a lot more pigeons."**

Then:

> **"Why are there so many pigeons?"**

And finally:

> **"I have made a terrible mistake."**

**Start the day.**

**Feed the pigeons.**

**Watch the numbers go up.**
