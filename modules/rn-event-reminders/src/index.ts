/* eslint-disable prefer-promise-reject-errors */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */


/**
 * @description 用法同react-native-calendar-reminders 一样
 * @example  https://github.com/wmcmahan/react-native-calendar-reminders
 * @import { RNEventReminders } from 'rn-event-reminders';
*/

import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  'The package \'rn-event-reminders\' doesn\'t seem to be linked. Make sure: \n\n' +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const RnEventReminders = NativeModules.RnEventReminders
  ? NativeModules.RnEventReminders
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    },
  );

export type AuthorizationStatus = 'denied' | 'restricted' | 'authorized' | 'undetermined';
export type RecurrenceFrequency = 'daily' | 'weekly' | 'monthly' | 'yearly';

type ISODateString = string;

/** iOS ONLY - GeoFenced alarm location */
interface AlarmStructuredLocation {
  /** The title of the location. */
  title: string;
  /** A value indicating how a location-based alarm is triggered. */
  proximity: 'enter' | 'leave' | 'none';
  /** A minimum distance from the core location that would trigger the calendar event's alarm. */
  radius: number;
  /** The geolocation coordinates, as an object with latitude and longitude properties. */
  coords: { latitude: number; longitude: number };
}

export interface Alarm<D = ISODateString | number> {
  /** When saving an event, if a Date is given, an alarm will be set with an absolute date. If a Number is given, an alarm will be set with a relative offset (in minutes) from the start date. When reading an event this will always be an ISO Date string */
  date: D;
  /** iOS ONLY - The location to trigger an alarm. */
  structuredLocation?: AlarmStructuredLocation;
}

export interface ReminderEventBase {
  /** The title for the reminder. 创建时传入的title值, 该对象不用设置 */
  title?: string;
  /** The start date of the reminder event in ISO format */
  startDate?: ISODateString;
  /* The date by which the reminder should be completed. */
  dueDate: ISODateString;
  /** The location associated with the reminder event. */
  location?: string;
  /** Unique id for the calendar where the event will be saved. Defaults to the device's default reminder. */
  calendarId?: string;
  /** iOS ONLY - The notes associated with the reminder event. */
  notes: string;
  /** The alarms associated with the reminder, as an array of alarm objects. */
  alarms?: Array<Alarm<ISODateString | number>>;
  /** The simple recurrence frequency of the reminder event. */
  recurrence?: RecurrenceFrequency;
  /** The interval between instances of this recurrence. For example, a weekly recurrence rule with an interval of 2 occurs every other week. Must be greater than 0. */
  recurrenceInterval?: string;
  /** iOS ONLY - The url associated with the calendar event. */
  url?: string;
}

interface ReminderCalendar {
  /** Unique calendar ID. */
  id: string;
  /** The calendar’s title. */
  title: string;
  /** The source object representing the account to which this calendar belongs. */
  source: string;
  /** Indicates if the calendar allows events to be written, edited or removed. */
  allowsModifications: boolean;
}

export interface ReminderEventReadable extends ReminderEventBase {
  /** Unique id for the reminder. */
  id: string;
  /** (read only) The date on which the reminder was completed. */
  completionDate?: ISODateString;
  /* The calendar containing the reminder. */
  calendar?: ReminderCalendar;
  /** A Boolean value determining whether or not the reminder is marked completed. */
  isCompleted?: boolean;
}

export default class RNEventReminders {

  public static authorizationStatus(): Promise<AuthorizationStatus> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.authorizationStatus();
    }
    return Promise.reject('android not support');
  }

  public static requestPermissions(): Promise<AuthorizationStatus> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.authorizeEventStore();
    }
    return Promise.reject('android not support');
  }
  /** 获取所有的事项 */
  public static fetchAllReminders(): Promise<ReminderEventReadable[]> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.fetchAllReminders();
    }
    return Promise.reject('android not support');
  }

  /** 获取已经完成的事项 */
  public static fetchCompletedReminders(startDate?: ISODateString, endDate?: ISODateString): Promise<ReminderEventReadable[]> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.fetchCompletedReminders(startDate, endDate);
    }
    return Promise.reject('android not support');
  }

  /** 获取未完成的事项 */
  public static fetchIncompleteReminders(startDate?: ISODateString, endDate?: ISODateString): Promise<ReminderEventReadable[]> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.fetchIncompleteReminders(startDate, endDate);
    }
    return Promise.reject('android not support');
  }

  /** 获取指定id的事项 */
  public static findReminderById(id: string): Promise<ReminderEventReadable> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.findReminderById(id);
    }
    return Promise.reject('android not support');
  }

  /**
   * @description 保存事项
   * @param title 标题
   * @param {notes: '提醒详细说明', startDate: 提醒时间, alarms: [{ date: -5 表示提前5分钟提醒 }]  } details 事项详情
   * @returns - Promise resolving to saved event's ID.
  */
  public static saveReminder(title: string ,details: ReminderEventBase): Promise<string> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.saveReminder(title,details);
    }
    return Promise.reject('android not support');
  }

  // @returns - Promise resolving to saved event's ID.
  public static updateReminder(reminderId: string, details: ReminderEventReadable): Promise<string> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.updateReminder(reminderId, details);
    }
    return Promise.reject('android not support');

  }

  /* 根据事件ID移除指定事项 */
  public static removeReminder(eventId: string): Promise<boolean> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.removeReminder(eventId);
    }
    return Promise.reject('android not support');

  }

  // @returns - Promise resolving to saved event's ID.
  public static addAlarm(eventId: string, alarm: Alarm): Promise<string> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.addAlarm(eventId, alarm);
    }
    return Promise.reject('android not support');

  }

  // @returns - Promise resolving to saved event's ID.
  public static addAlarms(eventId: string, alarms: Alarm[]): Promise<string> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.addAlarms(eventId, alarms);
    }
    return Promise.reject('android not support');

  }

  /**
   * @description 保存提醒日历
   * @param {title: 日历名称, 不传则是默认提醒事项}
   * @param {color: 日历颜色}
   * @param {id: '日历ID' 用于更新日历标题和颜色}
   * @returns { 日历ID }
  */
  public static saveReminderCalendar(calendar: {title?: string, color?: string, id?: string}): Promise<string> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.saveReminderCalendar(calendar);
    }
    return Promise.reject('android not support');
  }

  public static removeCalendar(calendarId: string): Promise<boolean> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.removeCalendar(calendarId);
    }
    return Promise.reject('android not support');
  }

  public static findReminderCalendars(): Promise<ReminderCalendar[]> {
    if(Platform.OS === 'ios'){
      return RnEventReminders.findReminderCalendars();
    }
    return Promise.reject('android not support');
  }

}
