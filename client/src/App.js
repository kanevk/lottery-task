import React from 'react';
import './App.css';
import { ReactComponent as Loader } from './loader.svg';

const DOMAIN = 'localhost:3002'

// ---------------------------------------- Utils --------------------------------------------------
const presentNumberAsMoney = (number) => {
    return number.toLocaleString('us-US', { style: 'currency', currency: 'USD' })
}

const handleAPIResponse = (resp) => {
    const contentType = resp.headers.get('content-type')
    var isJSON = contentType && contentType.indexOf('application/json') !== -1

    var nextResponse = isJSON ? resp.json() : resp.text()

    return resp.ok ? nextResponse : nextResponse.then(data => Promise.reject(data))
}

const fetchJSON = (url, customSettings = {}) => {
    let settings = Object.assign(
        {},
        customSettings,
        {
            cache: "no-cache",
            headers: { 'Content-Type': 'application/json' }
        }
    )

    return fetch(url, settings).then(handleAPIResponse)
}

// ---------------------------------------- Components --------------------------------------------
const CellComponent = ({ number, selected, numberToggled, selectionDisabled }) => {
    const classNames = `cell ${selected ? 'selected' : ''}`
    const handleClick = (e) => {
        e.preventDefault()
        numberToggled(number)
    }

    return (
        <button className={classNames}
            key={number}
            disabled={selected ? false : selectionDisabled}
            onClick={handleClick}
        >{number}</button>
    )
}

const TicketComponent = ({ submitNewTicket }) => {
    const [nickname, changeNickname] = React.useState('')
    const [selectedNumbers, changeSelectedNumbers] = React.useState([])

    const selectedCount = selectedNumbers.length

    const numberToggled = (number) => {
        if (selectedNumbers.includes(number)) {
            changeSelectedNumbers(selectedNumbers.filter((n) => n !== number))
        } else {
            changeSelectedNumbers([number, ...selectedNumbers])
        }
    }
    const handleNicknameChange = (e) => { changeNickname(e.target.value) }
    const handleSubmit = (e) => {
        e.preventDefault()
        submitNewTicket(nickname, selectedNumbers)
    }

    return (
        <div className="Ticket">
            <form onSubmit={handleSubmit}>
                <input type="text" value={nickname} placeholder="Nickname" maxLength="10" onChange={handleNicknameChange} />
                <div className="Ticket-cells">
                    {
                        [...Array(49).keys()].map((i) =>
                            CellComponent({
                                numberToggled,
                                number: i + 1,
                                selected: selectedNumbers.includes(i + 1),
                                selectionDisabled: selectedCount === 6,
                            })
                        )
                    }
                </div>
                <button className="button" disabled={selectedCount !== 6 || !nickname}>Enroll</button>
                <p>{selectedCount}/6 selected</p>
            </form>
        </div>
    )
}

const WinningRowComponent = ({ ticket: { nickname, numbers, prize, winner } }) => {
    const decoratedNumbers = numbers.toString().split(',').join(', ')

    return (
        <div className="WinnersTable-row">
            <div className="WinnersTable-row-cells"><span role="img" aria-label="Human">👤</span> {nickname}</div>
            <div className="WinnersTable-row-cells"><span role="img" aria-label="Number six">➏</span> {decoratedNumbers}</div>
            <div className="WinnersTable-row-cells"><span role="img" aria-label="Flying money">💸</span> {presentNumberAsMoney(prize)}</div>
        </div>
    )
}

const WinnersTableComponent = ({ winningTickets }) => {
    const [renderedCount, changeRenderedCount] = React.useState(100)
    // A naive but simple way to do a pagination
    const handleScroll = (e) => {
        renderedCount === winningTickets.length || changeRenderedCount(winningTickets.length)
    }

    return (
        <div className="WinnersTable" onScroll={handleScroll}>
            {winningTickets.slice(0, renderedCount).map((ticket, i) => (<WinningRowComponent ticket={ticket} key={i} />))}
        </div>
    )
}

const App = () => {
    const [menuActivity, setMenuActivity] = React.useState({ enrollPage: true })
    const [winningTickets, changeWinningTickets] = React.useState(null)
    const [ticketsCount, changeTicketsCount] = React.useState(null);

    const syncTicketsCount = () => {
        fetchJSON(`http://${DOMAIN}/lottery/tickets`)
            .then(({ tickets_count }) => { changeTicketsCount(tickets_count) })
    }
    const handleDrawClick = () => {
        fetchJSON(`http://${DOMAIN}/lottery/draws`, { method: 'POST' })
            .then(({ tickets }) => {
                const localTickets = tickets
                    .map(ticket => ({ ...ticket, prize: parseFloat(ticket.prize) }))
                    .sort((first, second) => second.prize - first.prize)

                changeWinningTickets(localTickets)
            })
    }

    const handleNewTicketSubmission = (nickname, numbers) => {
        fetchJSON(`http://${DOMAIN}/lottery/tickets`, {
            method: 'POST',
            body: JSON.stringify({ ticket: { nickname, numbers } })
        }).then(_ => {
            changeWinningTickets(null)
            setMenuActivity({ drawPage: true })
        })
    }

    if (!ticketsCount) {
        syncTicketsCount()
        return (<div> Loading... </div>)
    }

    if (menuActivity.drawPage) {
        syncTicketsCount()
    }

    const enrollPageClasses = `Menu-item ${menuActivity.enrollPage ? 'active' : ''}`
    const drawPageClasses = `Menu-item ${menuActivity.drawPage ? 'active' : ''}`

    return (
        <div className="App">
            <div className="App-header">
                <h2>Lottery 6/49</h2>
            </div>
            <div className="App-body">
                <div className="Menu">
                    <span onMouseOver={() => { setMenuActivity({ enrollPage: true }) }} className={enrollPageClasses}>
                        <span>Play now</span>
                    </span>
                    <span onMouseOver={() => { setMenuActivity({ drawPage: true }) }} className={drawPageClasses}>
                        <span>Draw</span>
                    </span>
                </div>
                <div className="App-body-main">
                    {
                        menuActivity.enrollPage ?
                            <TicketComponent submitNewTicket={handleNewTicketSubmission} />
                            :
                            <div className='DrawPage'>
                                <button className="button" onClick={handleDrawClick}> Find the winner </button>
                                <p><strong>{ticketsCount}</strong> tickets submited</p>
                                {winningTickets && <WinnersTableComponent winningTickets={winningTickets} />}
                            </div>
                    }
                </div>
            </div>
        </div>
    )
}

export default App;
