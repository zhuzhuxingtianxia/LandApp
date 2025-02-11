import type { TableColumn } from './index';

const Columns: TableColumn[] = [
  {
    title: '区域',
    dataIndex: 'a',
    key: 'a',
  },
  {
    title: '客户',
    dataIndex: 'b',
    key: 'b',
    sorter: true,
  },
  {
    title: '次数',
    dataIndex: 'c',
    key: 'c',
    sorter: true,
  },
  {
    title: '日人均',
    dataIndex: 'd',
    key: 'd',
    sorter: true,
  },
  {
    title: '周人均',
    dataIndex: 'e',
    key: 'e',
    sorter: true,
  },
  {
    title: '月人均',
    dataIndex: 'f',
    key: 'f',
    sorter: true,
  },
];

const Datas = [
  { a: '北区', b: 125, c: 1943, d: 2.0, e: 12.0, f: 36 },
  { a: '东二区', b: 125, c: 1843, d: 2.4, e: 12.5, f: 30 },
  { a: '东一区', b: 120, c: 1903, d: 2.8, e: 12.8, f: 38 },
  { a: '南区', b: 150, c: 1933, d: 2.7, e: 12.6, f: 36 },
];

export { Columns, Datas };
