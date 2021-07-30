/**
 * Some Additional comment
 */
declare module "meteor/janmp:sdui-table"
{
  interface MeteorDataAutoTableProps {
    sourceName?: string;
    listSchemaBridge: any;
    usePubSub: boolean;
    rowsCollection: any;
    rowCountCollection: any;
    query: object;
    perLoad?: number;
    canEdit?: boolean;
    formSchemaBridge: any;
    canSearch?: boolean;
    canAdd?: boolean;
    onAdd?: boolean;
    canDelete?: boolean;
    //* @default "Soll der Eintrag wirklich gelöscht werden?"
    deleteConfirmation?: string;
    onDelete?: () => void;
    canExport?: boolean;
    onExportTable?: () => void;
    onRowClick?: () => void;
    autoFormChildren: any;
    formDisabled?: boolean;
    formReadOnly?: boolean;
    useSort?: boolean;
    getRowMethodName?: () => string;
    getRowCountMethodName?: () => string;
    rowPublicationName?: string;
    rowCountPublicationName?: string;
    submitMethodName?: string;
    deleteMethodName?: string;
    fetchEditorDataMethodName?: string;
    setValueMethodName?: string;
    exportRowsMethodName?: string;
    viewTableRole?, editRole?, exportTableRole?: string;
  }

  export default function MeteorDataAutoTable(props: MeteorDataAutoTableProps): JSX.Element;
}