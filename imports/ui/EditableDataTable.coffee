import React, {useState, useEffect, useRef} from 'react'
# import {Button, Icon, Modal} from 'semantic-ui-react'
import DataTable from './DataTable'
import ErrorBoundary from './ErrorBoundary'
import {ConfirmationModal, FormModal} from 'meteor/janmp:sdui-forms'

export default EditableDataTable = ({
  name
  listSchemaBridge, formSchemaBridge
  rows, totalRowCount, loadMoreRows, onRowClick,
  sortColumn, sortDirection, onChangeSort, useSort
  canSearch, search, onChangeSearch
  canAdd, onAdd
  canDelete, onDelete, deleteConfirmation
  canEdit, mayEdit, submit
  autoFormChildren, formDisabled, formReadOnly
  loadEditorData
  onChangeField,
  canExport, onExportTable
  mayExport
  isLoading,
  overscanRowCount
}) ->

  onAdd ?= ->
    openModal {}

  loadEditorData ?= ({id}) -> console.log "loadEditorData id: #{id}"

  [modalOpen, setModalOpen] = useState false
  [model, setModel] = useState {}

  [confirmationModalOpen, setConfirmationModalOpen] = useState false
  [idForConfirmationModal, setIdForConfirmationModal] = useState ''

  handleOnDelete =
    unless canDelete
      -> console.error 'handleOnDelete has been called despite canDelete false'
    else
      ({id}) ->
        console.log 'handleOnDelete', {id, deleteConfirmation}
        if deleteConfirmation?
          setIdForConfirmationModal id
          setConfirmationModalOpen true
        else
          onDelete {id}

  openModal = (formModel) ->
    setModel formModel
    setModalOpen true


  submitAndClose = (d) -> submit?(d).then -> setModalOpen false

  if canEdit
    onRowClick =
      ({rowData, index}) ->
        if formSchemaBridge is listSchemaBridge
          openModal rows[index]
        else
          loadEditorData id: rowData._id
          ?.then openModal

  <>
    {
      if mayEdit
        <FormModal
          schemaBridge={formSchemaBridge}
          onSubmit={submitAndClose}
          model={model}
          isOpen={modalOpen}
          onRequestClose={-> setModalOpen false}
          children={autoFormChildren}
          disabled={formDisabled}
          readOnly={formReadOnly}
        />
    }
    {
      if canDelete and deleteConfirmation?
        <ConfirmationModal
          isOpen={confirmationModalOpen}
          setIsOpen={setConfirmationModalOpen}
          text={deleteConfirmation}
          onConfirm={-> onDelete id: idForConfirmationModal}
        />
    }
    <ErrorBoundary>
      <DataTable
        {{
          name
          schemaBridge: listSchemaBridge,
          rows, totalRowCount, loadMoreRows, onRowClick,
          sortColumn, sortDirection, onChangeSort, useSort
          canSearch, search, onChangeSearch
          canAdd, onAdd
          canDelete, onDelete: handleOnDelete
          canEdit, mayEdit
          onChangeField,
          canExport, onExportTable
          mayExport
          isLoading
          overscanRowCount
        }...}
      />
    </ErrorBoundary>
  </>