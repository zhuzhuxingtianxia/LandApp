# rn-event-reminders

`"rn-event-reminders": "link:./modules/rn-event-reminders",`

```
/* ===========================添加事项到提醒事项 仅iOS================================= */

const requestReminderPermissions = async () => {
  try {
    const status: AuthorizationStatus = await RNEventReminders.authorizationStatus();
    console.log(status);
    if (status === 'undetermined') {
      const newStatus = await RNEventReminders.requestPermissions();
      console.log(newStatus);
      return newStatus;
    }
    return status;
  } catch (error) {
    console.log(error);
  }
};

const findReminderById = async (id: string) => {
  const status = await requestReminderPermissions();
  if (status !== 'authorized') {
    console.log('提醒事项未授权');
    return;
  }
  try {
    const reminder = await RNEventReminders.findReminderById(id);
    console.log(reminder);
    return reminder;
  } catch (error) {
    console.log(error);
  }
};
/**
 *示例：
 * saveReminder('提醒测试', {
 *   notes: '测试提醒详细说明',
 *   dueDate: dayjs(new Date(new Date().getTime() + 10 * 60 * 1000)).format('YYYY-MM-DD HH:mm:ss'),
 *   alarms: [{
 *     date: -5,
 *  }],
 * });
 * @param {title} 事件标题
 * @param {detail: ReminderEventBase} 事件详情
 * @returns {reminderId}
 */
const saveReminder = async (title: string, detail: ReminderEventBase) => {
  const status = await requestReminderPermissions();
  if (status !== 'authorized') {
    console.log('提醒事项未授权');
    return;
  }

  try {
    const reminderCalendars = await RNEventReminders.findReminderCalendars();

    const reminderCalendar = reminderCalendars.find((calendar) => calendar.title === displayName);
    if (reminderCalendar) {
      detail.calendarId = reminderCalendar.id;
    }else {
      const calendarId = await RNEventReminders.saveReminderCalendar({ title: displayName });
      detail.calendarId = calendarId;
    }
    if(detail.startDate && !detail.startDate.endsWith('Z')) {
      detail.startDate = new Date(detail.startDate).toISOString();
    }
    if(detail.dueDate && !detail.dueDate.endsWith('Z')) {
      detail.dueDate = new Date(detail.dueDate).toISOString();
    }
    const reminderId = await RNEventReminders.saveReminder(title, detail);
    console.log(reminderId);
    return reminderId;
  } catch (error) {
    console.log(error);
  }
};

const deleteReminder = async (id: string) => {
  const status = await requestReminderPermissions();
  if (status !== 'authorized') {
    console.log('提醒事项未授权');
    return;
  }
  try {
    const reminder = await RNEventReminders.removeReminder(id);
    console.log(reminder);
    return reminder;
  } catch (error) {
    console.log(error);
  }
};

const fetchAllReminders = async () => {
  const status = await requestReminderPermissions();
  if (status !== 'authorized') {
    console.log('提醒事项未授权');
    return;
  }
  try {
    const reminders = await RNEventReminders.fetchAllReminders();
    console.log(reminders);
    return reminders;
  } catch (error) {
    console.log(error);
  }
};

```

