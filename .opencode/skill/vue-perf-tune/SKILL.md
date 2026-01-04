---
name: vue-perf-tune
description: Improve Vue 3 + Vite performance without UX changes
---

# Vue Performance Tuning

Improve Vue 3 + Vite performance without UX changes.

## Allowed Actions

- Code splitting (dynamic import)
- Refactor reactive hot paths
- Memoization (computed, shallowRef)
- Remove dead components

## Forbidden Actions

- UI redesign
- API contract changes
- Feature removal

## Validation

- Bundle size reduced
- Lighthouse score unchanged or better

## Techniques

### Code Splitting

```typescript
// BEFORE: Eager import
import HeavyComponent from './HeavyComponent.vue'

// AFTER: Lazy load
const HeavyComponent = defineAsyncComponent(
  () => import('./HeavyComponent.vue')
)
```

### Route-based Splitting

```typescript
// router/index.ts
const routes = [
  {
    path: '/dashboard',
    component: () => import('../pages/Dashboard.vue')
  }
]
```

### Reactive Optimization

```typescript
// BEFORE: Deep reactivity (expensive)
const state = reactive({ nested: { deep: { value: 1 } } })

// AFTER: Shallow reactivity (when deep not needed)
const state = shallowReactive({ nested: { deep: { value: 1 } } })
```

### Computed Caching

```typescript
// BEFORE: Inline calculation in template
<template>
  <div>{{ items.filter(x => x.active).length }}</div>
</template>

// AFTER: Cached computed
<script setup>
const activeCount = computed(() => items.filter(x => x.active).length)
</script>
<template>
  <div>{{ activeCount }}</div>
</template>
```

### v-once for Static Content

```vue
<template>
  <!-- Static content that never changes -->
  <header v-once>
    <h1>{{ appTitle }}</h1>
  </header>
</template>
```

### List Virtualization

```typescript
// For long lists, use virtual scrolling
import { RecycleScroller } from 'vue-virtual-scroller'

<RecycleScroller
  :items="longList"
  :item-size="50"
  v-slot="{ item }"
>
  <ListItem :item="item" />
</RecycleScroller>
```

## Bundle Analysis

```bash
# Analyze bundle size
pnpm build
npx vite-bundle-visualizer

# Check for duplicate dependencies
npx depcheck
```

## Scope

- `frontend/src/**`
- `frontend/vite.config.ts`
