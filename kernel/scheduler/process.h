#pragma once

#include <scheduler/scheduler.h>

task_t *pcreate(unsigned long pa, unsigned long va, bool kernel);