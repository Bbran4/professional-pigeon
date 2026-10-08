# PROFESSIONAL PIGEON

> **A 2D incremental idle game about feeding pigeons, building a flock, and turning an ordinary park into an increasingly ridiculous pigeon ecosystem.**

---

## Overview

**PROFESSIONAL PIGEON** is a 2D single-player incremental idle game built around a deliberately simple idea:

**Give pigeons food. Watch what happens. Make it bigger.**

The player does **not** directly control a pigeon. Instead, the player manages the conditions that make the park come alive, and can lightly *nudge* the chaos with a few optional interactions (throwing bread, startling pigeons).

You begin with a quiet city park, a small supply of basic food, and a single pigeon.

The player starts a day, provides food, and watches the pigeon arrive, fly down from a tree, search for food, eat, and generate resources. Those resources are spent on upgrades that make the next day more productive, and more ridiculous.

The player is not the hero.

**The pigeons are the show.**

---

# Design Pillars

1. **Pigeons are the content.** Behaviour, personality and animation matter more than menus.
2. **The park is the progress bar.** Upgrades should visibly change the world.
3. **Watching is the game, poking is the garnish.** The game must be fun with zero input, and *more* fun with a little.
4. **Escalation is the joke.** Treat absurd pigeon activity as completely normal.
5. **Complexity is earned.** Do not add systems until the loop is fun without them.

---

# Core Concept

Professional Pigeon is built around a short, repeatable incremental loop:

**Start Day → Provide Food → Pigeons Arrive → Pigeons Eat → Earn Points → Buy Upgrades → Start Next Day**

During the day the player may optionally **throw bread** and **startle pigeons** (see [Player Interaction](#player-interaction)).

A successful upgrade should not only make a number larger. It should make the park **look and behave differently**.

---

# The Day Loop

Each run represents one **day in the park**.

The prototype day currently lasts **60 seconds**. This is the first real target for the park loop, and later upgrades can increase it further.

During the day:

1. Food is introduced into the park by the player.
2. Pigeons notice the food.
3. Pigeons arrive from the surrounding environment.
4. Pigeons fly, land, walk, search, compete and eat.
5. Eating generates points.
6. More pigeons can arrive as the player's upgrades improve.
7. The park becomes increasingly active.
8. The day ends when the timer reaches zero.

> **Rule:** a day ends when the timer runs out, *not* when the food runs out. The player can throw bread throughout the day, up to the current bread stock limit.

The player then receives a results screen showing what happened.

Example:

**DAY 7 COMPLETE**

- Pigeons attracted: 14
- Food eaten: 23
- Points earned: 184
- Maximum pigeons present: 11
- Highlight: *Gerald stole 4 crumbs from Pam.*
- New unlocks available

---

# Player Interaction

The player is the unseen manager of the park, but a good idle game gives you something to poke at while you wait. These interactions are **optional**: the game must be fully playable without them, and they should become progressively automated by upgrades.

### Tap to Throw Bread

Tap/click a spot in the park to throw bread there.

- Limited by a **bread stock** that refills over time (or per day), so it is an active bonus rather than a requirement.
- Lets the player decide *where* pigeons gather, which makes feeding areas and bird feeders matter.
- Becomes automated later ("Auto-Thrower"), which feels powerful *because* the player used to do it by hand.

### Startle: Click

Clicking a pigeon startles it. It flaps off, then returns after a short delay.

- Pure juice at first: funny, satisfying, harmless.
- Gives the player a way to break up a pigeon hogging the food.

### Startle: Hover (Scare Zone)

Moving the mouse near pigeons scares them away from the cursor.

Design notes, because this one needs care:

- **Hovering is a trade-off, not a free action.** Scaring pigeons away from food slows eating, so the player must choose *where* to scare and *when*.
- It must not conflict with tap-to-throw. Throwing bread should still feel good, and scaring should never prevent it. Suggested approach: a small scare radius around the cursor that only affects pigeons on the ground, with an obvious visual cue (a subtle ring or a cursor change).
- It should have a purpose beyond novelty. Good uses: pushing a bossy pigeon off a pile so shy pigeons can eat, shooing pigeons off a spot, and later, scaring away threats like gulls or cats.
- It should be **toggleable or disableable** for accessibility, and easy to avoid on touch devices (where "hover" does not exist; use a tap/press-and-hold equivalent).
- If it turns out to be annoying (accidental scares while reaching for the UI), restrict it to a "scare mode" or only while a key/button is held.

### Golden Bread (Special Drops)

Occasionally a special item appears (golden bread, a dropped sandwich, a lucky crumb). Clicking it gives a bonus. This is the classic "reward attention without demanding it" mechanic.

### Interaction Principles

- Never required to progress.
- Always cheap, immediate and funny.
- Every manual interaction should have a matching automation upgrade later.

---

# The Important Part: Watching Numbers Go Up

Incremental games work because progression is both **numerical and visible**.

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

The initial view is a relatively contained 2D scene rather than a traditional platforming level.

The player is represented by a throwing hand entering from the edge of the screen. A person can be added later as presentation, but is not a controllable character.

The park can contain:

- Trees
- Grass
- Paths
- Benches
- Food
- Bird feeders
- Water
- Pigeon houses
- Statues
- Decorative objects
- Background buildings
- Other park visitors
- Pigeons

The initial park should remain deliberately simple. New systems should be introduced as the player progresses.

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
- Reacting to the player's cursor

## Pigeon Behaviour

The first pigeon prototype follows a state-driven behaviour loop:

**Perch → Notice Food → Fly Down → Land → Search → Eat → Idle → Fly Away**

As the game develops, behaviours are layered on:

**Food nearby**

> Walk toward it.

**Another pigeon nearby**

> Join the group, or compete with it.

**Water available**

> Drink or bathe.

**Too much activity**

> Fly away.

**Cursor nearby / clicked**

> Startle and flee, then return.

**Pigeon house available**

> Return to it.

The goal is not a complicated simulation. The goal is **believable, entertaining behaviour**.

## Personality

Pigeons should not be 20 copies of the same loop. Give each pigeon a small set of personality traits that change how it behaves:

- **Greedy:** moves faster toward food and eats more per visit.
- **Shy:** waits at the edge of a crowd and flees easily.
- **Bossy:** chases other pigeons off food.
- **Lazy:** idles more, walks rather than flies.
- **Jumpy:** startles at the slightest movement.

Traits should be **visible** (posture, speed, small cosmetic differences) and ideally **named**. A pigeon the player recognises, such as the one that always gets chased off or the one that hoards, is worth more than a +10% upgrade.

## Competition and Crowding

Pigeons racing for the same crumb is one of the funniest, most watchable things the game can produce. It also explains, in the world itself, why more food, more space and more feeding areas matter.

- Multiple pigeons targeting the same food should be resolved visibly (a race, a chase, a steal).
- Crowded food should produce shoving, hopping and flapping.
- Bossy pigeons can monopolise a pile until the player scares them off.

## Pigeon Population

The first major progression goal is simply to attract more pigeons.

| Stage | Pigeons | Notes |
|-------|---------|-------|
| 1 | 1 | One food source |
| 2 | 3 | More food becomes available |
| 3 | 5-10 | Multiple feeding opportunities |
| 4 | 10-20 | The park starts to feel busy |
| 5 | 20+ | The player manages an actual flock |

Population growth should be visible and satisfying.

---

# Food

Food is the primary driver of the early game.

The first food source is intentionally simple:

## Bread

Bread is thrown into the park by the player during a day.

Pigeons detect it, move toward it and eat it. Eating bread generates points.

Later, additional food types can be unlocked:

- Bread
- Seeds
- Grain
- Worms
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

## Currency Plan

The prototype currently uses *Food* both as the thing pigeons eat **and** the thing the player spends, which will confuse players. The plan is to separate them:

- **Food (item):** the physical thing placed in the park. Bread, seeds, worms.
- **Points (currency):** earned when pigeons eat. Banked at the end of each day and spent on upgrades. This is the **only** currency in the early game.
- **Coins (later):** a second persistent currency, only introduced if a system genuinely needs it (e.g. larger purchases, new parks).

Additional currencies should only be introduced when they create a meaningful new decision.

The game should not become a spreadsheet with pigeons painted on it.

---

# Upgrades

Upgrades are the main source of long-term progression.

> **Upgrades should change what happens in the park, not merely increase numbers.**

**Rule of thumb:** for every purely numeric upgrade, there should be one that unlocks something the player can *see*.

### Numeric upgrades (keep these few and meaningful)

- More Bread
- Faster Feeding (shorter gaps between throws)
- Longer Day
- Better Food (higher value)

### Visible upgrades

- **Bird Feeder:** pigeons perch and queue.
- **Water Bath:** new drinking and bathing animations and a new pigeon state.
- **Pigeon House:** pigeons have somewhere to return to.
- **Statue:** pigeons gather on it and generate a passive bonus.
- **Second Feeder:** a different human with different throwing behaviour (kids throw wildly, an old man scatters seeds in a pattern).
- **Bigger Park:** more room for the flock.
- **Auto-Thrower:** automates the player's tap-to-throw.
- **Bread Stock:** more bread to throw manually.
- **Scare Range:** a larger hover-scare radius (and, later, scare strength).

### Interaction upgrades

- Bigger bread stock
- Faster stock refill
- Golden bread appears more often
- Automation of manual actions

---

# Meaningful Choices

A skill tree where you eventually buy everything is not a tree. Where possible, add real decisions:

- **Branching paths:** e.g. a "Bread Baron" path (more food, bigger payouts) versus a "Pigeon Whisperer" path (more pigeons, better behaviour).
- **Trade-offs:** a bigger flock means more chaos and a chance of negative events (a dropped sandwich, a fight, a stolen lunch).
- **Day modifiers** chosen before starting a day:
  - *Rainy day:* fewer pigeons, but each is worth more.
  - *Lunch rush:* more humans, more bread, more chaos.
  - *Quiet morning:* longer day, fewer events.

---

# Unlock Progression

A possible progression path:

**Bread**

↓

**More Bread**

↓

**Tap to Throw**

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

> Several pigeons feeding and squabbling.

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

The player is represented by a hand at the edge of the park that throws bread. This is presentation for the manager interaction, not a controllable character.

The player's interaction is:

**Primary (menus):**

- Start Day
- Buy Upgrade
- Unlock Feature
- Start Next Day
- Manage persistent progression

**Optional (in the park):**

- Tap to throw bread
- Click pigeons to startle them
- Hover to scare pigeons away
- Click special drops

There is no platforming.

There is no direct pigeon movement control.

There is no traditional combat.

There is no requirement for the player to do anything during a day.

The player creates the conditions. **The pigeons do the rest.**

---

# Idle Gameplay

The game should remain satisfying even when the player is doing very little.

The player presses a button.

The park reacts.

Numbers increase.

Pigeons move around.

Points accumulate.

The player buys an upgrade.

The next day becomes more productive.

The loop repeats.

The goal is to create the pleasant incremental feeling of:

> **"Just one more upgrade."**

---

# Automation

Automation should gradually reduce the amount of manual intervention required.

### Beginning

Player starts the day and can throw up to 5 pieces of bread by hand. The throw uses an aim marker and visible arc, but manual throwing is optional to the long-term design.

### Later

Bread is thrown automatically at intervals (Auto-Thrower).

### Later

Multiple food sources activate automatically.

### Later

Pigeons naturally return to the park.

### Later still

Days start automatically, and the park runs while the player is away (offline progress).

### Eventually

The park becomes a largely self-sustaining ecosystem.

Automation is not about removing the game. It is about making the player's growing ecosystem feel increasingly powerful.

---

# The Skill Tree

The existing progression system remains an important part of the game, but it needs to be **pruned and reshaped** for the idle structure.

Rather than upgrading a player character, upgrades should affect:

- Food production
- Food spawn quantity
- Food spawn frequency
- Pigeon attraction
- Pigeon population
- Feeding efficiency
- Point generation
- Park features
- Day length
- Automation
- Interaction (bread stock, scare range)
- New pigeon types
- New environments

The tree should provide meaningful choices rather than a list of percentage increases.

### Skills to Remove or Rework

Several existing skills are leftovers from the side-scrolling prototype and no longer fit:

- Faster Flight, Stronger Flaps
- Dive, Peck
- Longer Glide, Longer Sprint, Longer Air Burst
- Full Pockets (carry capacity)
- Food Finder, Double Crumbs, Rush Hour, Better Scavenging (rework into park equivalents)

### Target Starter Tree (roughly six upgrades)

1. **More Bread** (more bread per day)
2. **Faster Feeding** (shorter delay between throws)
3. **Longer Day** (10s → longer)
4. **More Pigeons** (population cap)
5. **Bread Stock** (more bread to throw by hand)
6. **Bird Feeder** (first visible park feature)

Expand only once this small tree is fun.

---

# Day Length

The prototype day lasts **10 seconds** so the loop can be tested quickly. Later upgrades increase the length of a day.

For example:

**10 seconds**

↓

**20 seconds**

↓

**30 seconds**

↓

**60 seconds**

↓

**90 seconds**

↓

**2 minutes**

↓

**5 minutes**

Longer days allow more activity to occur and make stronger upgrades more valuable.

Day length should be balanced carefully so that increasing it feels useful without simply making the game slower.

---

# Events and Pacing Within a Day

A day should have a shape, not just a timer.

- **Quiet start:** one or two pigeons, a little bread.
- **Mid-day rush:** more pigeons, more food, more competition.
- **Dramatic finish:** a late event such as a dog, a child chasing pigeons, or a golden bread drop.

Possible future event systems:

- Cats
- Dogs
- Children
- Park visitors
- Other birds (gulls)
- Rain
- Wind
- Special food drops
- Crowds
- Park events
- Seasonal changes

These should be added only after the basic loop is fun.

> **Do not add complexity just because we can.**

---

# Day Results and Highlights

The results screen should reinforce "pigeons are the show."

In addition to totals, show **highlights** generated from what actually happened:

- "Gerald stole 4 crumbs from Pam."
- "A record 11 pigeons were present at once."
- "Brenda was scared off 6 times and kept coming back."
- "The golden bread was claimed by a pigeon with no manners."

This makes every day feel distinct and gives the flock stories.

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

Each location should introduce something genuinely new. A new background alone is not enough.

---

# Prestige and Long-Term Structure

Most successful incremental games have a reset mechanic. The title *Professional Pigeon* suggests a natural framing: **a career ladder.**

An early sketch:

**Hobbyist → Amateur → Professional → Expert → Legend**

Moving to a new city or park could reset the park but keep **Reputation**, giving a mechanical reason for "Multiple Parks" to exist.

This is a planning note, not a build target. It exists so currency and save-data decisions made now don't block it later.

---

# Pigeon Types

Different pigeon types can eventually be introduced.

- Common Pigeon
- Fat Pigeon
- Fast Pigeon
- Hungry Pigeon
- Fancy Pigeon
- Messenger Pigeon
- Giant Pigeon
- Rare Pigeon

Different types may have different behaviours or resource bonuses.

This system should come **after** the basic pigeon loop has been proven, and should build on the personality system rather than replace it.

---

# Comedy

The game should be humorous without requiring constant jokes.

The comedy comes from the escalation of an otherwise ordinary park.

At the beginning:

> One person feeds one pigeon.

Later:

> A dozen pigeons are aggressively occupying the park.

Later still:

> There is a dedicated pigeon house.

Eventually:

> The player has somehow created a pigeon civilization.

The humour comes from treating increasingly absurd pigeon activity as completely normal.

### Comedy Tools

- A running, deadpan **news ticker**: "Local council baffled by pigeon surge."
- Absurd late-game unlocks: pigeon union, pigeon mayor, pigeon-run bakery, professional certifications.
- Dry, understated UI text.
- Named pigeons with consistent personalities.

---

# Long-Term Progression

The long-term goal is not simply to produce larger numbers. It is to transform the park.

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

Pigeons should be visually appealing and immediately readable. The park should be interesting enough to watch without overwhelming the player.

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

The game is no longer designed around traditional side-scrolling platformer movement. The camera frames the park as a stage on which the autonomous systems play out.

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
│   ├── Pigeon AI (one brain per pigeon)
│   ├── Pigeon States
│   ├── Pigeon Personality
│   └── Pigeon Types
│
├── Interaction
│   ├── Bread Throwing
│   ├── Startle (click / hover)
│   └── Special Drops
│
├── Resources
│   ├── Food (items)
│   ├── Points
│   └── Coins (later)
│
├── Day System
│   ├── Day Timer
│   ├── Day Start
│   ├── Day End
│   ├── Day Events
│   └── Day Results / Highlights
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
