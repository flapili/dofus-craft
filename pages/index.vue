<script setup lang="ts"></script>

<template>
  <div class="size-full flex flex-col sm:flex-row">
    <ItemPicker />
    <ToCraftPanel v-if="!supportMultiWindows()" class="border-l-3 border-black" />
  </div>
</template>
